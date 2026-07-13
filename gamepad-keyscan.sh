#!/data/data/com.termux/files/usr/bin/bash
set -u

GETEVENT="/system/bin/getevent"
MODE="direct"
ACTION="watch"

usage() {
  cat <<USAGE
用法:
  ./gamepad-keyscan.sh
      在 Termux 中直接监听，若需要会自动尝试 su。

  ./gamepad-keyscan.sh --adb
      通过 adb shell 监听，适合无 root 但已开启无线调试的情况。

  ./gamepad-keyscan.sh --list
      列出输入设备能力。

  ./gamepad-keyscan.sh --adb --list
      通过 adb shell 列出输入设备能力。

按 Ctrl+C 退出监听。
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --adb) MODE="adb" ;;
    --list) ACTION="list" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $arg"; usage; exit 1 ;;
  esac
done

can_read_input() {
  for f in /dev/input/event*; do
    [ -e "$f" ] || continue
    [ -r "$f" ] && return 0
  done
  return 1
}

run_getevent() {
  local args="-t"
  [ "$ACTION" = "list" ] && args="-lp"

  if [ "$MODE" = "adb" ]; then
    command -v adb >/dev/null 2>&1 || {
      echo "未找到 adb。可先安装: pkg install android-tools" >&2
      exit 1
    }
    adb shell "$GETEVENT $args"
    return
  fi

  if can_read_input; then
    "$GETEVENT" $args
  elif command -v su >/dev/null 2>&1 && su -c true >/dev/null 2>&1; then
    su -c "$GETEVENT $args"
  else
    cat >&2 <<ERR
没有读取 /dev/input/event* 的权限。

解决方式二选一:
1. root 手机后运行本脚本，它会自动使用 su。
2. 无 root：开启无线调试，然后用:
   pkg install android-tools
   adb pair 127.0.0.1:配对端口
   adb connect 127.0.0.1:调试端口
   ./gamepad-keyscan.sh --adb
ERR
    exit 1
  fi
}

if [ "$ACTION" = "list" ]; then
  run_getevent
  exit $?
fi

echo "正在监听手柄/输入设备事件……插入手柄后按键、摇杆、方向键。Ctrl+C 退出。" >&2
echo "输出字段: 类型 设备 linux键值 事件名 Android映射 状态/数值" >&2
echo >&2

run_getevent | awk '
function hnorm(h, w) {
  h=tolower(h)
  gsub(/^0x/, "", h)
  while (length(h) < w) h = "0" h
  return h
}

function hex2dec(h,    i,c,n,p) {
  h=tolower(h)
  gsub(/^0x/, "", h)
  n=0
  for (i=1; i<=length(h); i++) {
    c=substr(h,i,1)
    if (c>="0" && c<="9") p=c+0
    else if (c>="a" && c<="f") p=10+index("abcdef",c)-1
    else p=0
    n=n*16+p
  }
  return n
}

function signed32(h,    n) {
  n=hex2dec(h)
  if (n >= 2147483648) n -= 4294967296
  return n
}

BEGIN {
  key["0130"]="BTN_SOUTH / BTN_A";      android["0130"]="KEYCODE_BUTTON_A(96)"
  key["0131"]="BTN_EAST / BTN_B";       android["0131"]="KEYCODE_BUTTON_B(97)"
  key["0132"]="BTN_C";                  android["0132"]="KEYCODE_BUTTON_C(98)"
  key["0133"]="BTN_NORTH / BTN_X";      android["0133"]="KEYCODE_BUTTON_X(99)"
  key["0134"]="BTN_WEST / BTN_Y";       android["0134"]="KEYCODE_BUTTON_Y(100)"
  key["0135"]="BTN_Z";                  android["0135"]="KEYCODE_BUTTON_Z(101)"
  key["0136"]="BTN_TL / L1";            android["0136"]="KEYCODE_BUTTON_L1(102)"
  key["0137"]="BTN_TR / R1";            android["0137"]="KEYCODE_BUTTON_R1(103)"
  key["0138"]="BTN_TL2 / L2";           android["0138"]="KEYCODE_BUTTON_L2(104)"
  key["0139"]="BTN_TR2 / R2";           android["0139"]="KEYCODE_BUTTON_R2(105)"
  key["013a"]="BTN_SELECT";             android["013a"]="KEYCODE_BUTTON_SELECT(109)"
  key["013b"]="BTN_START";              android["013b"]="KEYCODE_BUTTON_START(108)"
  key["013c"]="BTN_MODE / HOME";        android["013c"]="KEYCODE_BUTTON_MODE(110)"
  key["013d"]="BTN_THUMBL / L3";        android["013d"]="KEYCODE_BUTTON_THUMBL(106)"
  key["013e"]="BTN_THUMBR / R3";        android["013e"]="KEYCODE_BUTTON_THUMBR(107)"

  key["0220"]="BTN_DPAD_UP";            android["0220"]="KEYCODE_DPAD_UP(19)"
  key["0221"]="BTN_DPAD_DOWN";          android["0221"]="KEYCODE_DPAD_DOWN(20)"
  key["0222"]="BTN_DPAD_LEFT";          android["0222"]="KEYCODE_DPAD_LEFT(21)"
  key["0223"]="BTN_DPAD_RIGHT";         android["0223"]="KEYCODE_DPAD_RIGHT(22)"

  key["0067"]="KEY_UP";                 android["0067"]="KEYCODE_DPAD_UP(19)"
  key["006c"]="KEY_DOWN";               android["006c"]="KEYCODE_DPAD_DOWN(20)"
  key["0069"]="KEY_LEFT";               android["0069"]="KEYCODE_DPAD_LEFT(21)"
  key["006a"]="KEY_RIGHT";              android["006a"]="KEYCODE_DPAD_RIGHT(22)"
  key["001c"]="KEY_ENTER";              android["001c"]="KEYCODE_DPAD_CENTER(23)"

  abs["0000"]="ABS_X";                  axis["0000"]="AXIS_X"
  abs["0001"]="ABS_Y";                  axis["0001"]="AXIS_Y"
  abs["0002"]="ABS_Z";                  axis["0002"]="AXIS_Z / L2或右摇杆相关"
  abs["0003"]="ABS_RX";                 axis["0003"]="AXIS_RX"
  abs["0004"]="ABS_RY";                 axis["0004"]="AXIS_RY"
  abs["0005"]="ABS_RZ";                 axis["0005"]="AXIS_RZ / R2或右摇杆相关"
  abs["0009"]="ABS_GAS";                axis["0009"]="AXIS_GAS"
  abs["000a"]="ABS_BRAKE";              axis["000a"]="AXIS_BRAKE"
  abs["0010"]="ABS_HAT0X";              axis["0010"]="AXIS_HAT_X / 十字键横向"
  abs["0011"]="ABS_HAT0Y";              axis["0011"]="AXIS_HAT_Y / 十字键纵向"
}

{
  line=$0
  gsub(/\r/, "", line)

  if (line ~ /^add device/) {
    cur=$NF
    printf("\n[设备接入] %s\n", cur)
    fflush()
    next
  }

  if (line ~ /^[[:space:]]*name:/) {
    name=line
    sub(/^[^"]*"/, "", name)
    sub(/".*$/, "", name)
    devname[cur]=name
    printf("  名称: %s\n", name)
    fflush()
    next
  }

  if (line !~ /\/dev\/input\/event[0-9]+:/) next

  sub(/^\[[^]]*\][[:space:]]*/, "", line)
  split(line, a, /[[:space:]]+/)

  path=a[1]
  sub(/:$/, "", path)

  type=hnorm(a[2],4)
  code=hnorm(a[3],4)
  value=hnorm(a[4],8)

  dev=(devname[path] != "" ? devname[path] : path)

  if (type == "0001") {
    state=value
    if (value == "00000001") state="DOWN"
    else if (value == "00000000") state="UP"
    else if (value == "00000002") state="REPEAT"

    k=(key[code] != "" ? key[code] : "UNKNOWN_KEY")
    m=(android[code] != "" ? android[code] : "-")

    printf("[KEY] %-28s linux=0x%s %-24s android=%-28s state=%s\n",
           dev, code, k, m, state)
    fflush()
  }
  else if (type == "0003") {
    an=(abs[code] != "" ? abs[code] : "UNKNOWN_ABS")
    ax=(axis[code] != "" ? axis[code] : "-")
    dec=signed32(value)

    printf("[ABS] %-28s linux=0x%s %-24s androidAxis=%-28s value=0x%s dec=%s\n",
           dev, code, an, ax, value, dec)
    fflush()
  }
}
'
