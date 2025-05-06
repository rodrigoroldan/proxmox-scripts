#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Script de provisionamento LXC “Step-CA” para Proxmox, baseado no padrão
# community-scripts/ProxmoxVE
# -----------------------------------------------------------------------------

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# stub das funções que buscam cabeçalho/descrição remoto,
# para evitar os 404/400 que você está vendo
get_header()     { :; }
get_description(){ :; }

# metadados
APP="Step-CA"
var_tags="${var_tags:-ca}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

# agora sim invocações normais, sem risk de falhar no header
header_info "$APP"
variables
color
catch_errors

function update_script() {
    # ignora erros na troca de header também aqui
    set +e; header_info "$APP"; set -e

    check_container_storage
    check_container_resources

    if [[ ! -x /usr/bin/step-ca ]]; then
        msg_error "Nenhuma instalação do ${APP} encontrada!"
        exit 1
    fi

    msg_info "Atualizando ${APP} no LXC"
    $STD apt-get update
    $STD apt-get -y upgrade
    msg_ok "Atualizado ${APP}"
    exit 0
}

start
build_container

# descrição customizada (stub acima faz nada e não falha)
description

msg_info "Instalando ${APP}"
$STD apt-get update
$STD apt-get install -y --no-install-recommends curl vim gpg ca-certificates
$STD curl -fsSL https://packages.smallstep.com/keys/apt/repo-signing-key.gpg -o /etc/apt/trusted.gpg.d/smallstep.asc && echo 'deb [signed-by=/etc/apt/trusted.gpg.d/smallstep.asc] https://packages.smallstep.com/stable/debian debs main' | tee /etc/apt/sources.list.d/smallstep.list
$STD apt-get update
$STD apt-get -y install step-cli step-ca
msg_ok "${APP} instalado"

# inicializa a CA se ainda não existir
if [[ ! -f /etc/step/config/ca.json ]]; then
  msg_info "Inicializando configuração do ${APP}"
  $STD step ca init \
    --name "Internal CA" \
    --dns "${HOSTNAME}" \
    --address ":8443" \
    --provisioner password
  msg_ok "${APP} inicializado"
fi

msg_ok "Concluído com sucesso!"
echo -e "${CREATING}${GN}${APP} configurado com sucesso!${CL}"
echo -e "${INFO}${YW} Acesse sua CA em:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}https://${IP}:8443${CL}"
