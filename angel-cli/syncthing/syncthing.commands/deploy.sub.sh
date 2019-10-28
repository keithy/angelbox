# sensible deploy.sub.sh
#
# by Keithy 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="deploy"
description="deploy this command suite to remote hosts"
usage=\
"$breadcrumbs --hosts         # list configured hosts and their tags
$breadcrumbs --tags=<a>,<b>  # select tagged hosts to deploy
$breadcrumbs --help          # this message"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

LISTHOSTS=false
INSTALL=false
UNINSTALL=false
tags=()

for arg in "$@"
do
  case "$arg" in
    --hosts|--list)
      LISTHOSTS=true
      tags=('all')
    ;;
    --install)
      INSTALL=true
    ;;
    --tags=* | --tag=*)
      IFS=',' tags=(${arg##--t*=}) #interpret (comma separated) as an array
    ;;
    --all)
      tags=('all')
    ;;
    --*)
    ;;
    -*)
    # ignore other options
    ;;
  esac
done
 
options=()

if $DRYRUN; then
  r_options+=('--dry-run')
fi

if $VERBOSE; then
  r_options+=('--verbose')
  ssh_options+=('-v')
fi

if $DDEBUG; then
  ssh_options+=('-vv')
fi

if $LISTHOSTS; then
  for host in ${sensible_host_names[@]}; do
    for tag in ${tags[@]}; do
      if [[ ",all,${sensible_tags[$host]}," == *,"$tag,"* ]]; then
        printf "$host (${sensible_tags[$host]}): ${sensible_deploy[$host]}\n"
      fi
    done
  done
  exit 0
fi

for host in ${sensible_host_names[@]}; do
  for tag in ${tags[@]}; do
    if [[ ",all,${sensible_tags[$host]}," == *,"$tag,"* ]]; then
 
      $LOUD && echo "${host}(${tag}):" ${sensible_deploy[$host]}
      $LOUD && echo rsync -a "${options[@]}"  "${rootCommandFile%/*}/*" "${sensible_deploy[$host]}"
      $DRYRUN && echo "dryrun:  --confirm required to proceed"
      $CONFIRM && rsync -a "${options[@]}" "${rootCommandFile%/*}/"* "${sensible_deploy[$host]}"
      
      install_src="${sensible_deploy[$host]##*:}/${rootCommandFile##*/}"    
      install_dest="${sensible_install[$host]:-${sensible_install["_default_"]}}/${rootCommandFile##*/}"
      $LOUD && $INSTALL && echo ssh "${ssh_options[@]}" "${sensible_deploy[$host]%:*}" "mkdir -p \"${install_dest%/*}\" && ln -s \"${install_src}\" \"${install_dest}\""
      $CONFIRM && $INSTALL && ssh "${ssh_options[@]}" "${sensible_deploy[$host]%:*}" "mkdir -p \"${install_dest%/*}\" && ln -s \"${install_src}\" \"${install_dest}\"" || true
    fi
  done
done

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."