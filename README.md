# Домашнее задание «Terraform. Yandex Cloud»

| | |
|---|---|
| **Студент** | Демин Илья Викторович |
| **GitHub репозиторий** | https://github.com/deminilyadev-maker/terraform-04.git |

---

# Оглавление

- [Задание 1](#задание-1)
- [Задание 2](#задание-2)
- [Задание 3](#задание-3)

---

# Задание 1

## Шаг 1. Создание двух виртуальных машин с помощью remote-модуля

На основе кода из демонстрации был создан Terraform-проект с использованием двух вызовов `remote`-модуля.

Были созданы две виртуальные машины, относящиеся к разным проектам:

- `marketing`;
- `analytics`.

Для обозначения принадлежности виртуальных машин использованы labels.

В конфигурации также используется `cloud-init`, которому передаётся SSH-ключ и шаблон `cloud-init.yml`.

---

## Шаг 2. Установка nginx

В файл `cloud-init.yml` была добавлена установка веб-сервера nginx.

После создания виртуальных машин nginx устанавливается автоматически при выполнении cloud-init.

---

## Шаг 3. Проверка созданных виртуальных машин

После выполнения Terraform были проверены созданные ресурсы с помощью Yandex Cloud CLI:

```bash
yc compute instance list
```

В результате были получены три работающие виртуальные машины проекта:

```text
develop-webs-1
develop-webs-0
stage-web-stage-0
```

### Скриншот

![Список виртуальных машин](screenshots/task1_vm_list.png)

---

## Шаг 4. Проверка параметров виртуальных машин

Параметры виртуальных машин были дополнительно проверены командой:

```bash
yc compute instance get --name develop-webs-1
```

и:

```bash
yc compute instance get --name develop-webs-0
```

Проверены:

- ID виртуальных машин;
- имя;
- зона;
- статус;
- CPU и RAM;
- сеть;
- внутренний и внешний IP;
- labels.

Пример labels:

```yaml
labels:
  owner: i.ivanov
  project: marketing
```

---

# Задание 2

## Шаг 1. Создание локального модуля VPC

Был создан локальный Terraform-модуль `vpc`.

Модуль создаёт два ресурса:

- одну сеть `yandex_vpc_network`;
- одну подсеть `yandex_vpc_subnet`.

Параметры сети и подсети передаются в модуль через переменные.

В частности, задаются:

- имя сети;
- зона;
- `v4_cidr_blocks`.

Пример вызова модуля:

```hcl
module "vpc_dev" {
  source     = "./vpc"
  env_name   = "develop"
  zone       = "ru-central1-a"
  cidr       = "10.0.1.0/24"
}
```

---

## Шаг 2. Проверка созданных ресурсов VPC

Для просмотра сетей была выполнена команда:

```bash
yc vpc network list
```

В результате была найдена сеть:

```text
develop
```

Для просмотра подсетей была выполнена команда:

```bash
yc vpc subnet list
```

В результате была найдена подсеть:

```text
develop-ru-central1-a
```

с диапазоном:

```text
10.0.1.0/24
```

### Скриншот

![Список подсетей Yandex Cloud](screenshots/task2_vpc_subnet_list.png)

---

## Шаг 3. Использование созданного VPC-модуля

Ресурсы `yandex_vpc_network` и `yandex_vpc_subnet` были заменены на ресурсы, создаваемые локальным модулем.

Необходимые параметры сети передаются в модуль через переменные.

Информация о созданной сети и подсети также возвращается через `output`.

---

## Шаг 4. Генерация документации

Для локального модуля VPC была подготовлена документация с помощью `terraform-docs`.

В результате структура проекта содержит отдельный каталог:

```text
vpc/
```

с конфигурацией локального модуля.

---

# Задание 3

## Шаг 1. Просмотр ресурсов в Terraform state

Перед удалением модулей был выведен список ресурсов Terraform state:

```bash
terraform state list
```

В состоянии находились ресурсы VPC и виртуальных машин, в том числе:

```text
module.example-vm.yandex_compute_instance.vm[0]
module.test-vm.yandex_compute_instance.vm[0]
module.test-vm.yandex_compute_instance.vm[1]
module.vpc.yandex_vpc_network.root_network
module.vpc.yandex_vpc_subnet.root_subnet
```

---

## Шаг 2. Удаление модулей VPC и VM из state

По условию задания модули `vpc` и `vm` были полностью удалены из Terraform state без удаления самих ресурсов в Yandex Cloud.

После удаления ресурсов из state они продолжили существовать в облаке.

---

## Шаг 3. Проверка ресурсов в Yandex Cloud

Для проверки существующих виртуальных машин была выполнена команда:

```bash
yc compute instance list
```

В результате были найдены:

```text
develop-webs-1
develop-webs-0
stage-web-stage-0
```

Также была проверена существующая подсеть:

```bash
yc vpc subnet list
```

---

## Шаг 4. Импорт ресурсов обратно в Terraform state

После удаления ресурсов из state они были импортированы обратно.

Пример импорта подсети:

```bash
terraform import 'module.vpc.yandex_vpc_subnet.root_subnet' <SUBNET_ID>
```

Для виртуальных машин были выполнены импорты:

```bash
terraform import 'module.test-vm.yandex_compute_instance.vm[0]' fhmi5174eh3h07ppcin3
```

```bash
terraform import 'module.test-vm.yandex_compute_instance.vm[1]' fhm95t3skh88bao0tvag
```

Также был импортирован ресурс виртуальной машины модуля `example-vm`.

После импорта был проверен Terraform state:

```bash
terraform state list
```

В state снова присутствуют ресурсы модулей:

```text
module.example-vm.yandex_compute_instance.vm[0]
module.test-vm.yandex_compute_instance.vm[0]
module.test-vm.yandex_compute_instance.vm[1]
module.vpc.yandex_vpc_network.root_network
module.vpc.yandex_vpc_subnet.root_subnet
```

### Скриншот

![Terraform state после импорта](screenshots/task3_state_list.png)

---

## Шаг 5. Проверка terraform plan

После завершения импорта выполнена проверка:

```bash
terraform plan
```

В результате Terraform не планирует создание или удаление ресурсов:

```text
Plan: 0 to add, 3 to change, 0 to destroy.
```

Все три изменения являются обновлением параметра:

```hcl
allow_stopping_for_update = true
```

Существенных изменений инфраструктуры нет:

- новые ВМ не создаются;
- существующие ВМ не удаляются;
- сеть не пересоздаётся;
- подсеть не пересоздаётся;
- изменения конфигурации виртуальных машин отсутствуют, кроме `allow_stopping_for_update`.

### Скриншот

![Финальный terraform plan](screenshots/task3_final_plan.png)

---

# Итог

В рамках домашнего задания:

- созданы и проверены виртуальные машины в Yandex Cloud;
- использованы Terraform-модули;
- создан локальный модуль VPC;
- создана сеть и подсеть через локальный модуль;
- ресурсы были удалены из Terraform state без удаления из облака;
- все необходимые ресурсы импортированы обратно;
- выполнена проверка `terraform plan`;
- после импорта отсутствуют операции `add` и `destroy`, то есть значимых изменений инфраструктуры нет.
