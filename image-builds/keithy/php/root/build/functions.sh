
function ENV {
  val="$2" ; [[ -z "$val" ]] && eval val="\$$1"
  echo "export $1=\"$val\"" > /etc/profile.d/$1.sh
  eval "$1=\"$val\"" 
}