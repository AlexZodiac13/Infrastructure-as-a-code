// Пример ресурса (Yandex Cloud) — адаптируйте под ваш провайдер / версию
// Добавьте labels = { group = "wp_app" } в ресурсы ВМ

// resource "yandex_compute_instance" "web" {
//   name = "web-${count.index}"
//   count = 2
//   resources {
//     cores = 2
//     memory = 2
//   }
//   network_interface {
//     subnet_id = yandex_vpc_subnet.subnet.id
//   }
//   labels = {
//     group = "wp_app"
//   }
// }

// Оставлено закомментированным — вы должны добавить реальные ресурсы и провайдеры
