#!/bin/sh

if [[ $TRAVIS_BUILD != "0" ]] && [[ -z $SSA_KEYS_JSON_PASSWORD ]]; then
  source ~/.bash_profile
fi

if [[ -z $SSA_KEYS_JSON_PASSWORD ]]; then
  echo "error: Decryption password for keys.json not found."
  exit 1
elif [[ -f Resources/keys.json.enc ]]; then
  openssl aes-256-cbc -k "${SSA_KEYS_JSON_PASSWORD}" -in Resources/keys.json.enc -out "$BUILT_PRODUCTS_DIR"/"$PRODUCT_NAME".app/keys.json -d
  exit $?
elif [[ -f Resources/keys.json ]]; then
  echo "warning: Unencrypted keys.json file should not be stored in the Resources folder."
  cp -R Resources/keys.json "$BUILT_PRODUCTS_DIR"/"$PRODUCT_NAME".app/keys.json
  exit $?
else
  echo "Unable to find either an encrypted or plaintext keys file."
  echo "You must either have keys stored in Resources/keys.json or an encrypted form of this file in Resources/keys.json.enc."
  echo "Note that the keys file should NOT be tracked by version control if it is not encrypted."
  exit 1
fi
