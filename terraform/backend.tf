terraform {
  backend "http" {
    address="https://old.owgrant.su/api/v4/projects/2/terraform/state/iacstate"
    lock_address="https://old.owgrant.su/api/v4/projects/2/terraform/state/iacstate/lock"
    unlock_address="https://old.owgrant.su/api/v4/projects/2/terraform/state/iacstate/lock"
    username="zodiac"
    lock_method="POST"
    unlock_method="DELETE"
    retry_wait_min=5
  }
}