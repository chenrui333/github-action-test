#!/bin/bash

create-robot-e2e-secret() {
  echo "Create robot-e2e-secret..."
  cd .github/workflows/scripts
  # sed -i "s|AUTOBOT_API_KEY_BASE64|${{secrets.AUTOBOT_API_KEY_BASE64}}|g" ./selenium/robot-e2e-secret.yml
  # sed -i "s|MASTER_PASSWORD_BASE64|${{secrets.MASTER_PASSWORD_BASE64}}|g" ./selenium/robot-e2e-secret.yml

  cat ./selenium/robot-e2e-secret.yml

  echo "Finished creating robot-e2e-secret!"
}

time create-robot-e2e-secret
