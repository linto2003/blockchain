#!/bin/bash
# Registers the 5 admins
# hospital-admin, pharmacy-admin, delivery-admin, customer-admin, orderer-admin

# Registers the admins
function registerAdmins {
    # 1. Set the CA Server Admin as FABRIC_CA_CLIENT_HOME
    source ./scripts/setclient.sh   caserver   admin

    # 2. Register hospital-admin
    echo "Registering: hospital-admin"
    ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
    fabric-ca-client register --id.type client --id.name hospital-admin --id.secret pw --id.affiliation hospital --id.attrs $ATTRIBUTES
    
    # 3. Register pharmacy-admin
    echo "Registering: pharmacy-admin"
    ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
    fabric-ca-client register --id.type client --id.name pharmacy-admin --id.secret pw --id.affiliation pharmacy --id.attrs $ATTRIBUTES

    # 4. Register orderer-admin
    echo "Registering: orderer-admin"
    ATTRIBUTES='"hf.Registrar.Roles=orderer"'
    fabric-ca-client register --id.type client --id.name orderer-admin --id.secret pw --id.affiliation orderer --id.attrs $ATTRIBUTES

    # 5. Register customer-admin
    echo "Registering: customer-admin"
    ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
    fabric-ca-client register --id.type client --id.name customer-admin --id.secret pw --id.affiliation customer --id.attrs $ATTRIBUTES


    # 6. Register delivery-admin
    echo "Registering: delivery-admin"
    ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
    fabric-ca-client register --id.type client --id.name delivery-admin --id.secret pw --id.affiliation delivery --id.attrs $ATTRIBUTES

}

# Setup MSP
function setupMSP {
    mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts

    echo "====> $FABRIC_CA_CLIENT_HOME/msp/admincerts"
    cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts
}

# Enroll admin
function enrollAdmins {
    # 1. hospital-admin
    echo "Enrolling: hospital-admin"

    ORG_NAME="hospital"
    source ./scripts/setclient.sh   $ORG_NAME   admin
    checkCopyYAML
    fabric-ca-client enroll -u http://hospital-admin:pw@localhost:7054

    setupMSP

    # 2. customer-admin
    echo "Enrolling: customer-admin"

    ORG_NAME="customer"
    source ./scripts/setclient.sh   $ORG_NAME   admin
    checkCopyYAML
    fabric-ca-client enroll -u http://customer-admin:pw@localhost:7054

    setupMSP

    # 3. orderer-admin
    echo "Enrolling: orderer-admin"

    ORG_NAME="orderer"
    source ./scripts/setclient.sh   $ORG_NAME   admin
    checkCopyYAML
    fabric-ca-client enroll -u http://orderer-admin:pw@localhost:7054

    setupMSP

    # 2. pharmacy-admin
    echo "Enrolling: pharmacy-admin"

    ORG_NAME="pharmacy"
    source ./scripts/setclient.sh   $ORG_NAME   admin
    checkCopyYAML
    fabric-ca-client enroll -u http://pharmacy-admin:pw@localhost:7054

    setupMSP

    # 2. delivery-admin
    echo "Enrolling: delivery-admin"

    ORG_NAME="delivery"
    source ./scripts/setclient.sh   $ORG_NAME   admin
    checkCopyYAML
    fabric-ca-client enroll -u http://delivery-admin:pw@localhost:7054

    setupMSP
}

# If client YAML not found then copy the client YAML before enrolling
# YAML picked from setup/config/multi-org-ca/yaml.0/ORG-Name/*
function    checkCopyYAML {
     if [ -f "$FABRIC_CA_CLIENT_HOME/fabric-ca-client.yaml" ]
    then 
        echo "Using the existing Client Yaml for $ORG_NAME  admin"
    else
        echo "No Config file "
    fi
}

echo "========= Registering ==============="
registerAdmins
echo "========= Enrolling ==============="
enrollAdmins
echo "==================================="