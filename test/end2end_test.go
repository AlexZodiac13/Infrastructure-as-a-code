package test

import (
	"crypto/tls"
	"database/sql"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"golang.org/x/crypto/ssh"
	mysql_driver "github.com/go-sql-driver/mysql"
)

var folder = flag.String("folder", "", "Folder ID in Yandex.Cloud")
var sshKeyPath = flag.String("ssh-key-pass", "", "Private ssh key for access to virtual machines")
var sshUser = flag.String("ssh-user", "zodiac", "SSH user for VM")
var skipDBCheck = flag.Bool("skip-db-check", false, "Skip DB connectivity check if true")
var createNetwork = flag.Bool("create-network", true, "Create a new VPC network")
var networkID = flag.String("network-id", "", "Existing network id to reuse if create-network is false")

var fallbackUsers = []string{"ubuntu", "yandex", "root"}

func TestEndToEndDeploymentScenario(t *testing.T) {
	fixtureFolder := "../terraform/"

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := &terraform.Options{
			TerraformDir: fixtureFolder,

			Vars: map[string]interface{}{
				"yc_folder":     *folder,
				"create_network": *createNetwork,
				"network_id":     *networkID,
			},
		}

		test_structure.SaveTerraformOptions(t, fixtureFolder, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		t.Log("Run some tests...")

		terraformOptions := test_structure.LoadTerraformOptions(t, fixtureFolder)

		// test load balancer ip existing
		loadbalancerIPAddress := terraform.Output(t, terraformOptions, "load_balancer_public_ip")
		if loadbalancerIPAddress == "" {
			t.Fatal("Cannot retrieve the public IP address value for the load balancer.")
		}

		// test ssh connect
		vmLinuxPublicIPAddress := terraform.Output(t, terraformOptions, "vm_linux_public_ip_address")
		if vmLinuxPublicIPAddress == "" {
			t.Fatal("Cannot retrieve the VM public IP address.")
		}

		// read private key once
		key, err := ioutil.ReadFile(*sshKeyPath)
		if err != nil {
			t.Fatalf("Unable to read private key: %v", err)
		}

		signer, err := ssh.ParsePrivateKey(key)
		if err != nil {
			t.Fatalf("Unable to parse private key: %v", err)
		}

		// build list of users to try (primary + fallbacks)
		usersToTry := append([]string{*sshUser}, fallbackUsers...)

		var sshConn *ssh.Client
		var lastErr error

		for _, user := range usersToTry {
			sshConfig := &ssh.ClientConfig{
				User: user,
				Auth: []ssh.AuthMethod{
					ssh.PublicKeys(signer),
				},
				HostKeyCallback: ssh.InsecureIgnoreHostKey(),
				Timeout:         30 * time.Second,
			}

			// try with retries because VM cloud-init may take time to add key
			for attempt := 1; attempt <= 3; attempt++ {
				sshConn, lastErr = ssh.Dial("tcp", fmt.Sprintf("%s:22", vmLinuxPublicIPAddress), sshConfig)
				if lastErr == nil {
					t.Logf("SSH connection established with user %s on attempt %d", user, attempt)
					break
				}
				// give some time and retry
				time.Sleep(time.Duration(attempt*5) * time.Second)
			}

			if lastErr == nil {
				break // connected
			}
			t.Logf("Failed ssh attempts for user %s: %v", user, lastErr)
		}

		if sshConn == nil {
			// Provide debug hints
			var sb strings.Builder
			sb.WriteString("Cannot establish SSH connection to vm-linux public IP address. Tried users: ")
			sb.WriteString(strings.Join(usersToTry, ", "))
			sb.WriteString(". Error: ")
			sb.WriteString(fmt.Sprintf("%v", lastErr))
			sb.WriteString(".\nCheck:\n- that the public key file used by Terraform equals the private key file used in tests;\n- metadata of VM (ssh-keys) contains the expected key and username;\n- security groups or firewall rules allow port 22 from the runner's IP.")
			t.Fatalf(sb.String())
		}
		defer sshConn.Close()

		sshSession, err := sshConn.NewSession()
		if err != nil {
			t.Fatalf("Cannot create SSH session to vm-linux public IP address: %v", err)
		}
		defer sshSession.Close()

		if err := sshSession.Run("echo ok"); err != nil {
			t.Fatalf("Failed to run command on VM via SSH: %v", err)
		}

		if !*skipDBCheck {
			dbHosts := terraform.OutputList(t, terraformOptions, "database_host_fqdn")
			dbUser := terraform.Output(t, terraformOptions, "db_user")
			dbPassword := terraform.Output(t, terraformOptions, "db_password")
			dbName := terraform.Output(t, terraformOptions, "db_name")

			if len(dbHosts) == 0 {
				t.Fatalf("No DB hosts found in outputs")
			}

			// register TLS config to satisfy require_secure_transport=ON
			mysql_driver.RegisterTLSConfig("custom", &tls.Config{
				InsecureSkipVerify: true,
			})

			// Попробуем подключиться к первому хосту по TLS
			dsn := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s?charset=utf8mb4&parseTime=true&tls=custom", dbUser, dbPassword, dbHosts[0], dbName)
			db, err := sql.Open("mysql", dsn)
			if err != nil {
				t.Fatalf("Unable to open DB connection: %v", err)
			}
			defer db.Close()

			db.SetConnMaxLifetime(time.Second * 10)
			// Здесь — если Ping успешен, тест продолжится; иначе упадёт с ошибкой
			if err := db.Ping(); err != nil {
				t.Fatalf("Cannot ping DB: %v", err)
			}
		}

		successPath := filepath.Join(fixtureFolder, ".test-data", "validate_success")
		if err := os.MkdirAll(filepath.Dir(successPath), 0o755); err != nil {
			t.Logf("Warning: cannot create .test-data folder: %v", err)
		} else {
			if err := os.WriteFile(successPath, []byte(time.Now().Format(time.RFC3339)), 0o644); err != nil {
				t.Logf("Warning: cannot write validate_success file: %v", err)
			} else {
				t.Logf("Validation marker written to %s", successPath)
			}
		}
	})

	test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, fixtureFolder)
		terraform.Destroy(t, terraformOptions)
	})
}
