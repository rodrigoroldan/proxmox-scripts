#!/usr/bin/env bash
msg_info "1"
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Rodrigo Roldan
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/smallstep/certificates
msg_info "Pre Init Vars"
APP="Step-CA"
msg_info "Init Vars"
var_tags="${var_tags:-ca}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
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
        msg_error "No ${APP} installation found!"
        exit
    fi

    msg_info "Updating ${APP} in LXC"
    $STD apt-get update
    $STD apt-get -y upgrade
    msg_ok "Updated ${APP} in LXC"
    exit
}
msg_info "Pre Start"
start
msg_info "Pre build_container"
build_container
msg_info "Pre description"
description

msg_info "Installing ${APP}"
$STD apt-get update
$STD apt-get install -y curl ca-certificates gnupg
$STD curl -fsSL https://packagecloud.io/install/repositories/smallstep/cli/script.deb.sh | bash
$STD apt-get install -y step-ca
msg_ok "${APP} installed"

# Optional: initialize the CA if not already configured
if [[ ! -f /etc/step/config/ca.json ]]; then
  msg_info "Initializing ${APP} configuration"
  $STD step ca init \
    --name "Internal CA" \
    --dns "${HOSTNAME}" \
    --address ":8443" \
    --provisioner password
  msg_ok "${APP} initialized"
fi

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}https://${IP}:8443${CL}"
