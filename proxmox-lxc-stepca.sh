#!/usr/bin/env bash

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Your Name
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/smallstep/step

APP="Step-CA"

var_tags="${var_tags:-ca}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -x /usr/bin/step-ca ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Updating $APP LXC"
  $STD apt-get update
  $STD apt-get -y upgrade
  $STD apt-get install -y step-ca
  msg_ok "Updated $APP LXC"
  exit
}

start
build_container

description

msg_info "Installing $APP"
$STD apt-get update
$STD apt-get install -y curl ca-certificates gnupg
$STD curl -fsSL https://packagecloud.io/install/repositories/smallstep/cli/script.deb.sh | bash
$STD apt-get install -y step-ca
msg_ok "$APP Installed"

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access your CA at:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}https://${IP}:8443${CL}"
