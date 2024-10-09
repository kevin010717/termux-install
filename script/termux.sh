#!/data/data/com.termux/files/usr/bin/bash
#set -x
chmod +x "$0"

RED_COLOR='\e[1;31m'
GREEN_COLOR='\e[1;32m'
YELLOW_COLOR='\e[1;33m'
BLUE_COLOR='\e[1;34m'
PINK_COLOR='\e[1;35m'
SHAN='\e[1;33;5m'
RES='\e[0m'

#todo
#calibre-web
#markdown-web
#gitbook
#chatgpt
#termux-api
#zerotier
#termux代理软件：v2ray singbox mihomo(clash.meta) dae crashshell 目前用magisk模块
#nnn.vim
#nnn filebrowser
#tmux常用cli aliases

install_update() {
  termux-reload-settings
  #termux-setup-storage
  termux-change-repo
  pkg update && pkg upgrade -y
  pkg i root-repo x11-repo -y
  pkg i rxfetch rust lazygit peaclock tty-clock android-tools openssh wget nethogs htop screen tmux ffmpeg tsu lux zsh gh git lazygit python-pip mpv iptables samba termux-services neovim nodejs bk slides glow tree neofetch -y
  pkg i cmatrix nyancat coreutils figlet toilet weechat fortune cowsay sl w3m greed moon-buggy -y
  pkg i ncmpcpp mpd cmus mpg123 tizonia man -y
  pkg i nnn ranger yazi mc -y
  pkg i ripgrep -y
  pkg i iperf3 -y
  curl -o termux-api.apk https://f-droid.org/repo/com.termux.api_51.apk
  wget -O termux-styling.apk https://f-droid.org/repo/com.termux.styling_1000.apk
  su -c pm install termux-api.apk termux-styling.apk
  rm termux-api.apk termux-styling.apk
  pip install youtube-dl yt-dlp you-get PySocks
  pip install lolcat
  #npm install mapscii -g
  #cargo install clock-tui bk
  #pip install epr-reader
  #tidal-dl
  #pkg install python clang libjpeg-turbo ffmpeg zlib -y
  #pip3 install --upgrade tidal-dl

  passwd
  whoami
  #ssh-keygen -t rsa && ssh-copy-id -i ~/.ssh/id_rsa.pub kevin@10.147.17.140

  ssh-keygen -t rsa -b 4096 -C “k511153362gmail.com” && cat ~/.ssh/id_rsa.pub
  read -p "更新github ssh keys" key && am start -a android.intent.action.VIEW -d https://github.com && ssh -T git@github.com
  git config --global user.email "k511153362@gmail.com"
  git config --global user.name "kevin010717"
  gh auth login

  read -p "clouddrive?(y/n):" choice
  case $choice in
  y)
    curl -fsSL "https://mirror.ghproxy.com/https://github.com/kevin010717/clouddrive2/blob/main/cd2-termux.sh" | bash -s install root mirror
    am start -a android.intent.action.VIEW -d http://127.0.0.1:19798/
    ;;
  *) ;;
  esac

  read -p "filebrowser?(y/n):" choice
  case $choice in
  y)
    mkdir .filebrowser
    wget -O .filebrowser/filebrowser.tar.gz https://github.com/filebrowser/filebrowser/releases/download/v2.29.0/linux-arm64-filebrowser.tar.gz
    tar -zxvf .filebrowser/filebrowser.tar.gz -C .filebrowser
    chmod +x .filebrowser/filebrowser
    sudo nohup ~/.filebrowser/filebrowser -a 0.0.0.0 -p 18650 -r /data/data/com.termux/files -d ~/.filebrowser/filebrowser.db --disable-type-detection-by-header --disable-preview-resize --disable-exec --disable-thumbnails --cache-dir ~/.filebrowser/cache >/dev/null 2>&1 &
    am start -a android.intent.action.VIEW -d http://127.0.0.1:18650
    ;;
  *) ;;
  esac

  read -p "calibreweb?(y/n):" choice
  case $choice in
  y)
    pip install --user -U calibreweb
    pip install tzdata
    nohup python ~/.local/lib/python3.12/site-packages/calibreweb/__main__.py >/dev/null 2>&1 &
    am start -a android.intent.action.VIEW -d http://127.0.0.1:8083
    ;;
  *) ;;
  esac

  read -p "qbittorrent?(y/n):" choice
  case $choice in
  y)
    wget https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-4.5.2_v2.0.8/aarch64-qbittorrent-nox
    mv aarch64-qbittorrent-nox /data/data/com.termux/files/usr/bin/qbittorrent
    chmod +x qbittorrent
    sudo qbittorrent
    ;;
  *) ;;
  esac

  read -p "samba?(y/n):" choice
  case $choice in
  y)
    mkdir $PREFIX/etc/samba
    sed 's#@TERMUX_HOME@/storage/shared#/data/data/com.termux/files/home#g' /data/data/com.termux/files/usr/share/doc/samba/smb.conf.example >$PREFIX/etc/samba/smb.conf
    pdbedit -a -u admin
    smbd
    smbclient -p 445 //127.0.0.1/internal -U admin
    ;;
  *) ;;
  esac

  read -p "biliup?(y/n):" choice
  case $choice in
  y)
    mkdir builds
    cd builds/
    git clone https://github.com/saghul/pycares
    pip install setuptools
    python setup.py install
    cd ~
    rm -r builds -y

    pip install --user -U streamlink biliup
    echo “export PATH="${HOME}/.local/bin:${PATH}"” >.bashrc && source .bashrc && echo $PATH
    mkdir .biliup && cd .biliup && biliup start
    am start -a android.intent.action.VIEW -d http://127.0.0.1:3000
    ;;
  *) ;;
  esac

  read -p "aria2?(y/n):" choice
  case $choice in
  y)
    pkg install aria2
    # aria2c --enable-rpc --rpc-listen-all
    pkg install git nodejs
    git clone https://github.com/ziahamza/webui-aria2.git
    mv webui-aria2 .webui-aria2
    nohup node ~/.webui-aria2/node-server.js >/dev/null 2>&1 &
    am start -a android.intent.action.VIEW -d http://127.0.0.1:8888
    echo "访问https://zsxwz.com/go/?url=https://github.com/ngosang/trackerslist添加tracker"
    ;;
  *) ;;
  esac

  read -p "chfs?(y/n):" choice
  case $choice in
  y)
    wget --no-check-certificate https://iscute.cn/tar/chfs/3.1/chfs-linux-arm64-3.1.zip
    unzip chfs-linux-arm64-3.1.zip
    mv chfs-linux-arm64-3.1 chfs
    mv chfs /data/data/com.termux/files/usr/bin/
    rm chfs-linux-arm64-3.1.zip
    nohup sudo chfs --port=1234 >/dev/null 2>&1 &
    am start -a android.intent.action.VIEW -d http://127.0.0.1:1234
    ;;
  *) ;;
  esac

  read -p "http-server?(y/n):" choice
  case $choice in
  y)
    pkg install nodejs
    npm install -g http-server
    http-server -a 127.0.0.1 -p 8090
    am start -a android.intent.action.VIEW -d http://127.0.0.1:8090
    ;;
  *) ;;
  esac

  read -p "code-server?(y/n):" choice
  case $choice in
  y)
    apt install tur-repo                  #安装软件源
    apt install code-server               #安装
    cat ~/.config/code-server/config.yaml #查看密码
    code-server
    am start -a android.intent.action.VIEW -d http://127.0.0.1:8080
    ;;
  *) break ;;
  esac

  read -p "nodeserver?(y/n):" choice
  case $choice in
  y)
    mkdir nodeserver
    cd nodeserver
    npm init
    npm install express --save
    cat <<EOF >>server.js
const express = require('express');
const app = express();
app.get('/', (req, res) => {
   res.send('Hello World!');
});
app.listen(3000, () => {
   console.log('Server is running at http://localhost:3000');
});
EOF

    node server.js
    am start -a android.intent.action.VIEW -d http://127.0.0.1:3000
    ;;
  *) break ;;
  esac

  read -p "leetcode-cli?(y/n):" choice
  case $choice in
  y)
    npm install -g leetcode-cli
    ;;
  *) break ;;
  esac

  #bash -c "$(curl -L l.tmoe.me)"
  #mytermux.git
}

install_config() {
  sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  git clone git@github.com:ruanyf/fortunes.github && mv ~/fortunes/data/* $PREFIX/share/games/fortunes/ && rm -rf ~/fortunes
  cat <<EOF >>~/.zshrc
  #neofetch
  rxfetch
  sshd
  figlet Hello,world! | lolcat
  fortune $PREFIX/share/games/fortunes/fortunes | lolcat
  fortune $PREFIX/share/games/fortunes/chinese | lolcat
  fortune $PREFIX/share/games/fortunes/tang300 | lolcat
  fortune $PREFIX/share/games/fortunes/song100 | lolcat
  cowsay -r what | lolcat
  cal | lolcat
  date | lolcat
  alias c='screen -q -r -D cmus || screen -S cmus $(command -v cmus)'
  #shell screen -d cmus
  alias calibreweb='python /data/data/com.termux/files/home/.local/lib/python3.12/site-packages/calibreweb/__main__.py'
  alias f="sl;nyancat -f 50 -n;cmatrix;"
  alias rainbow='yes "$(seq 231 -1 16)" | while read -r i; do printf "\x1b[48;5;${i}m\n" && sleep 0.02; done'
  alias g="glow ~/workspace/README.md"
  alias h="htop"
  alias n="nvim"
  alias sc="source ~/.zshrc"
  alias t="~/workspace/script/termux.sh | lolcat"
  alias y="yazi"
  alias gacp="git add . ; git commit -m "1" ;git push origin main"
  if ! pgrep -f "clouddrive" > /dev/null; then
    sudo nohup nsenter -t 1 -m -- /bin/bash -c "cd /data/data/com.termux/files/home/.clouddrive/ && sudo ./clouddrive" >/dev/null 2>&1 &
  fi
  if ! pgrep -f "filebrowser" > /dev/null; then
    sudo nohup ~/.filebrowser/filebrowser -a 0.0.0.0 -p 18650 -r /data/data/com.termux/files -d ~/.filebrowser/filebrowser.db --disable-type-detection-by-header --disable-preview-resize --disable-exec --disable-thumbnails --cache-dir ~/.filebrowser/cache >/dev/null 2>&1 &
  fi
  if ! pgrep -f "calibreweb" > /dev/null; then
    nohup python ~/.local/lib/python3.12/site-packages/calibreweb/__main__.py >/dev/null 2>&1 &
  fi
EOF
  source ~/.zshrc
  cat <<EOF >>~/.termux/termux.properties
  volume-keys = volume
  bell-character = ignore"
  extra-keys = [[ \
  {macro: ":w\n", display: W, popup: {macro: "", display: A}}, \
  {macro: "CTRL /", display: T, popup: {macro: "", display: A}}, \
  {macro: "CTRL b", display: B, popup: {macro: "", display: A}}, \
  {macro: "clear\n", display: C, popup: {macro: "", display: A}}, \
  {key: ESC, popup: {macro: "", display: A}}, \
  {key: CTRL, popup: {macro: "", display: A}}, \
  {key: TAB, popup: {macro: "", display: A}}, \
  {key: LEFT, popup: HOME}, \
  {key: RIGHT, popup: END}, \
  {key: UP, popup: PGUP}, \
  {key: DOWN, popup: PGDN}, \
  {key: KEYBOARD, popup: {macro: "clear\n", display:clear }} \
]]
EOF
  termux-reload-settings

  cp -r /data/data/com.termux/files/usr/share/doc/mpv ~/.config/ && cat <<EOF >>~/.config/mpv/mpv.conf
  volume-max=1000
  volume=200
  script-opts=ytdl_hook-ytdl_path=/data/data/com.termux/files/usr/bin/yt-dlp
EOF
  mkdir -p ~/bin && cat <<EOF >>~/bin/termux-url-opener
  pip install -U yt-dlp
  echo "1.download it" 
  echo "2.listen to it"  
  echo "3.generate QRcode"
  read choice 
  case \$choice in 
    1) yt-dlp --output "%(title)s.%(ext)s" --merge-output-format mp4 --embed-thumbnail --add-metadata -f "bestvideo[height<=1080]+bestaudio[ext=m4a]" \$1;; 
    2) mpv --no-video -v \$1;;
    3) echo \$1 | curl -F-=\<- qrenco.de;;
    *) mpv --no-video -v \$1;;
  esac
EOF
  ln -s $PREFIX/bin/nvim ~/bin/termux-file-editor
  read -p "结束，按回车键继续…" key
}

start_obs() {
  folder="/data/data/com.termux/files/home/video/"
  read -p "请输入您的推流地址和推流码(rtmp协议):" rtmp
  while true; do
    cd $folder
    for video in $(ls *.mp4); do
      echo "正在播放：${video}"
      echo $(date +%F%n%T)
      ffmpeg -re -i "$video" -preset ultrafast -vcodec libx264 -g 60 -b:v 2000k -c:a aac -b:a 128k -strict -2 -f flv ${rtmp}
      #ffmpeg -re -i "$video" -i "$folder/image.jpg" -filter_complex overlay=W-w-5:5 -c:v libx264 -c:a aac -b:a 192k -strict -2 -f flv ${rtmp}
    done
  done
}

start_gif() {
  find . -type f \( -iname \*.mp4 -o -iname \*.mkv \) >file1.txt
  mkdir -p img
  while IFS= read -r file; do
    echo "处理文件 $(basename "$file")"
    #    read -p "按回车继续"
    #获取时长并分段
    filename="$file"
    duration=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$filename") </dev/null
    step=$(echo "$duration / 13" | bc -l)
    echo $duration
    echo $step
    #获取素材
    for f in $(seq 1 12); do
      step_int=$(printf "%.0f" $step)
      pos=$((step_int * f))
      ffmpeg -hide_banner -loglevel panic -ss "$pos" -t 2 -i "$file" -r 15 -vf "scale=500:-1" img/$f.gif -y </dev/null
    done
    #拼接up素材
    ffmpeg -hide_banner -loglevel panic -i img/1.gif -i img/2.gif -i img/3.gif -filter_complex "[0:v][1:v][2:v]concat=n=3:v=1:a=0[outv]" -map "[outv]" -strict -2 img/up.gif -y </dev/null

    #拼接down素材
    ffmpeg -hide_banner -loglevel panic -i img/4.gif -i img/5.gif -i img/6.gif -filter_complex "[0:v][1:v][2:v]concat=n=3:v=1:a=0[outv]" -map "[outv]" -strict -2 img/down.gif -y </dev/null

    #拼接left素材
    ffmpeg -hide_banner -loglevel panic -i img/7.gif -i img/8.gif -i img/9.gif -filter_complex "[0:v][1:v][2:v]concat=n=3:v=1:a=0[outv]" -map "[outv]" -strict -2 img/left.gif -y </dev/null

    #拼接right素材
    ffmpeg -hide_banner -loglevel panic -i img/10.gif -i img/11.gif -i img/12.gif -filter_complex "[0:v][1:v][2:v]concat=n=3:v=1:a=0[outv]" -map "[outv]" -strict -2 img/right.gif -y </dev/null

    # 拼接素材
    # ffmpeg -y -v warning -i img\up.gif -i img\down.gif -filter_complex "[0:v]pad=iw:ih*2[a];[a][1:v]overlay=0:h,fps=10,scale=-1:358" "%%~ni.gif"
    ffmpeg -hide_banner -loglevel panic -y -v warning -i img/up.gif -i img/down.gif -i img/left.gif -i img/right.gif -filter_complex "[0:v]pad=iw*2:ih*2[a];[a][1:v]overlay=0:h[b];[b][2:v]overlay=w:0[c];[c][3:v]overlay=w:h,fps=15,scale=600:-1" $(basename "${file%.*}").gif </dev/null
    #    echo " ">$(basename "${file%}")
  done <file1.txt
  rm -r file1.txt img
}

start_thumbnails() {
  # 遍历当前目录下的所有 .mp4 和 .mkv 文件
  for video_file in *.mp4 *.mkv; do
    # 忽略非文件类型的东西（如目录）
    [[ -f "$video_file" ]] || continue

    local thumbnail_file="${video_file%.*}.png" # 生成缩略图文件名
    echo "正在处理视频文件：$video_file"

    # 使用 ffmpeg 生成缩略图
    sudo ffmpeg -hide_banner -loglevel panic -y \
      -i "$video_file" \
      -frames 1 \
      -vf "thumbnail,scale=1080:-1,tile=1X5:padding=10:color=white" \
      "$thumbnail_file"
  done
}

while true; do
  echo -e "1.install_update"
  echo -e "2.install_config"
  echo -e "3.start_obs"
  echo -e "4.start_gif"
  echo -e "5.start_thumbnails"
  read choice
  case $choice in
  1) time install_update ;;
  2) time install_config ;;
  3) time start_obs ;;
  4) time start_gif ;;
  5) time start_thumbnails ;;
  *) break ;;
  esac
done
cheetsheet_nvim() {
  echo -e "1.astronvim"
  echo -e "2.lazyvim"
  echo -e "3.lunarvim"
  echo -e "4.nvchad"
  read choice
  case $choice in
  1)
    if [ ! -d ~/.config/nvim.lunarvim ]; then
      mv ~/.config/nvim ~/.config/nvim.lunarvim
      mv ~/.config/nvim.astronvim ~/.config/nvim
      echo "lunarvim backuped"
      nvim
    elif [ ! -d ~/.config/nvim.lazyvim ]; then
      mv ~/.config/nvim ~/.config/nvim.lazyvim
      mv ~/.config/nvim.astronvim ~/.config/nvim
      echo lazyvim backuped
      nvim
    elif [ ! -d ~/.config/nvim.nvchad ]; then
      mv ~/.config/nvim ~/.config/nvim.nvchad
      mv ~/.config/nvim.astronvim ~/.config/nvim
      echo "nvchad backuped"
      nvim
    fi
    ;;
  2)
    if [ ! -d "~/.config/nvim.nvchad" ]; then
      mv ~/.config/nvim ~/.config/nvim.nvchad
      mv ~/.config/nvim.lazyvim ~/.config/nvim
      echo "nvchad backuped"
      nvim
    elif [ ! -d "~/.config/nvim.lunarvim" ]; then
      mv ~/.config/nvim ~/.config/nvim.lunarvim
      mv ~/.config/nvim.lazyvim ~/.config/nvim
      echo "lunarvim backuped"
      nvim
    elif [ ! -d "~/.config/nvim.astronvim" ]; then
      mv ~/.config/nvim ~/.config/nvim.astronvim
      mv ~/.config/nvim.lazyvim ~/.config/nvim
      echo "astronvim backuped"
      nvim
    fi
    ;;
  3)
    if [ ! -d "~/.config/nvim.nvchad" ]; then
      mv ~/.config/nvim ~/.config/nvim.nvchad
      mv ~/.config/nvim.lunarvim ~/.config/nvim
      echo "nvchad backuped"
      nvim
    elif [ ! -d "~/.config/nvim.lazyvim" ]; then
      mv ~/.config/nvim ~/.config/nvim.lazyvim
      mv ~/.config/nvim.lunarvim ~/.config/nvim
      echo "lazyvim backuped"
      nvim
    elif [ ! -d "~/.config/nvim.astronvim" ]; then
      mv ~/.config/nvim ~/.config/nvim.astronvim
      mv ~/.config/nvim.lunarvim ~/.config/nvim
      echo "astronvim backuped"
      nvim
    fi
    ;;
  4)
    if [ ! -d "~/.config/nvim.lunarvim" ]; then
      mv ~/.config/nvim ~/.config/nvim.lunarvim
      mv ~/.config/nvim.nvchad ~/.config/nvim
      echo "lunarvim backuped"
      nvim
    elif [ ! -d "~/.config/nvim.lazyvim" ]; then
      mv ~/.config/nvim ~/.config/nvim.lazyvim
      mv ~/.config/nvim.nvchad ~/.config/nvim
      echo "lazyvim backuped"
      nvim
    elif [ ! -d "~/.config/nvim.astronvim" ]; then
      mv ~/.config/nvim ~/.config/nvim.astronvim
      mv ~/.config/nvim.nvchad ~/.config/nvim
      echo "astronvim backuped"
      nvim
    fi
    ;;
  *) break ;;
  esac
}
cheetsheet_tmux() {
  cat <<EOF >>~/.tmux.conf
  set -g status off
  bind-key -n C-a send-prefix
EOF
}
cheetsheet_termux() {
  termux-battery-status
  termux-camera-info
  termux-contact-list
  termux-infrared-frequencies
  termux-telephony-cellinfo
  termux-telephony-deviceinfo
  termux-tts-engines
  termux-wifi-connectioninfo
  termux-wifi-scaninfo
  termux-brightness auto
  termux-camera-photo -c 0 termux-camera-photo.jpg
  rm -rf termux-camera-photo.jpg
  termux-clipboard-set PHP是世界上最好的语言
  termux-clipboard-get
  termux-infrared-transmit -f 20,50,20,30
  termux-location -p network
  termux-microphone-record -d -f 1.m4a
  termux-microphone-record -q
  rm 1.m4a
  termux-notification -t '国光的Termu通知测试' -c 'Hello Termux' --type default
  termux-toast -b white -c black Hello Termux
  termux-torch on
  termux-torch off
  termux-tts-speak 'Hello world!'
  termux-vibrate -f -d 3000
  termux-wallpaper -l -f
  termux-wifi-enable false
  termux-wifi-enable true
  termux-dialog confirm -i 'Hello Termux' -t 'confirm测试'
  termux-dialog checkbox -v 'Overwatch,GTA5,LOL' -t '平时喜欢玩啥游戏'
  termux-dialog date -d 'yyyy-MM-dd' -t '你的出生日期是?'
  termux-dialog radio -v '小哥哥,小姐姐' -t '你的性别是?'
  termux-dialog sheet -v '菜鸡,国光'
  termux-dialog spinner -v '国光,光光' -t '你最喜欢的博主是?'
  termux-dialog text -i '密码:' -t '请输入核弹爆炸密码'
  termux-dialog time -t '你每天多少点睡觉?'
}
