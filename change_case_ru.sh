#!/bin/bash

# Установить параметры по умолчанию
RECURSIVE=false
VERBOSE=false
CHANGE_CASE=""

# Функция для печати сообщения об использовании
usage() {
    echo "Применение: $0 [-ULMRV] <путь к файлу или каталогу>"
    echo "  -U      преобразовать имена файлов и каталогов в верхний регистр"
    echo "  -L      преобразовать имена файлов и каталогов в нижний регистр"
    echo "  -M      преобразовать первую букву каждого слова в именах файлов и каталогов в верхний регистр"
    echo "  -R      выполнять операцию рекурсивно для всех вложенных файлов и каталогов"
    echo "  -V      выводить информацию о выполняемых действиях"
}

# Разобрать параметры командной строки
while getopts "ULMRV" opt; do
  case $opt in
    U)
      CHANGE_CASE="/usr/bin/tr '[:lower:]' '[:upper:]'"
      ;;
    L)
      CHANGE_CASE="/usr/bin/tr '[:upper:]' '[:lower:]'"
      ;;
    M)
      CHANGE_CASE="/usr/bin/tr '[:upper:]' '[:lower:]' | /bin/sed -r 's/(\b\w)/\U\1/g'"
      ;;
    R)
      RECURSIVE=true
      ;;
    V)
      VERBOSE=true
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Функция для проверки того, является ли аргумент допустимым каталогом
is_directory() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Функция для проверки того, является ли аргумент файлом
is_file() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Получить ПУТЬ к файлу или каталогу для переименования
if [ $# -eq 0 ]; then
  /bin/echo "Укажите ПУТЬ к файлу или каталогу для переименования." >&2
  exit 1
fi
PATH="$1"

# Определение функцию для выполнения преобразования регистра
function convert_case {
  local OLD_NAME="$1"
    if is_file "$f"; then
      local FILE_NAME=$(/usr/bin/basename "$1")
      local DIR_PATH=$(/usr/bin/dirname "$1")
      local FILE_EXT="${FILE_NAME##*.}"
      local FILE_NAME_NO_EXT="${FILE_NAME%.*}"
      local NEW_FILE_NAME_NO_EXT=$(/bin/echo "$FILE_NAME_NO_EXT" | eval "$CHANGE_CASE")
      local NEW_NAME=$(/bin/echo "$DIR_PATH/$NEW_FILE_NAME_NO_EXT.$FILE_EXT")
    else
      local BASE_NAME=$(/usr/bin/basename "$1")
      local DIR_PATH=$(/usr/bin/dirname "$1")
      local NEW_BASE_NAME=$(/bin/echo "$BASE_NAME" | eval "$CHANGE_CASE")
      local NEW_NAME=$(/bin/echo "$DIR_PATH/$NEW_BASE_NAME")
    fi
  if [ "$OLD_NAME" != "$NEW_NAME" ]; then
    if [ "$VERBOSE" == true ]; then
      /bin/echo "$OLD_NAME -> $NEW_NAME"
    fi
    /bin/mv "$OLD_NAME" "$NEW_NAME"
  fi
}

# Переименование файла или каталога
if [ -f "$PATH" ]; then
  convert_case "$PATH"
elif [ -d "$PATH" ]; then
  if [ "$RECURSIVE" == true ]; then
    for f in $(/usr/bin/find "$PATH" -depth | /usr/bin/awk '{print length($0), $0}' | /usr/bin/sort -rn | /usr/bin/awk '{ print $2 }'); do
      convert_case "$f"
    done
  else
    convert_case "$PATH"
  fi
else
  /bin/echo "$PATH не является файлом или каталогом." >&2
  exit 1
fi

