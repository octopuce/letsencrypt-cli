#! /bin/bash

# path handling
OLD_PATH=`pwd`
APP_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# library loading
LIB_PATH="${APP_PATH}/bash_lib/" 
source "${LIB_PATH}/std.sh"

# For trap
function exit_function {
    cd $OLD_PATH
    # G'bye
    exit 0
}

# Run as root
run_as_root

# Capture exit events to execute our exit function 
trap "exit_function" INT TERM EXIT


# @todo: check required packages: PHP-CLI, MYSQL-CLIENT & SERVER


# Are the composer dependancies installed
if ! file_exists "${APP_PATH}/vendor/autoload.php"; then

    echo "Installing Composer dependancies"

    # Is there anything like composer around ?
    COMPOSER=`bin_path composer.phar`
    [ -z "$COMPOSER" ] && COMPOSER=`bin_path composer`

    if [ -z "$COMPOSER" ] ; then
        read -e -i "Y" -p "Would you like to install Composer automatically [Y/n]?: " INSTALL_COMPOSER
        if option_enabled INSTALL_COMPOSER ; then 
            
            # install_composer the ... ugly way
            [ -n bin_path "curl" ] && die 1 "Missing Curl."

            # install_composer the ... ugly way
            $(bin_path curl) -sS "https://getcomposer.org/installer" | sudo php -- --install-dir=/usr/local/bin
        else 
            die 1 "Missing composer, please refer to https://getcomposer.org/installer" 
        fi
    fi

    # run Composer
    $COMPOSER update

fi

# Attempts to generate the DB
if [ -n `bin_path mysqladmin` ] && mysqladmin status >/dev/null 2>&1; then 

    read -e -i "Y" -p "Would you create the database (user, schema)? [Y/n]: " HANDLE_DB
    
    # Lets go for SQL
    if option_enabled HANDLE_DB ; then

        # Attempt to use Debian default auth
        MYSQL_PATH=`bin_path mysql`
        if [ -f "/etc/mysql/debian.cnf" ] ; then 
            MYSQL_COMMAND="${MYSQL_PATH} --defaults-file=/etc/mysql/debian.cnf"
        else
            read -e -p "Please provide mysql root password" MYSQL_ROOT_PASSWORD
            MYSQL_COMMAND="${MYSQL_PATH} -uroot --password=${MYSQL_ROOT_PASSWORD}"
        fi
        TMP_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        SUFFIX=$(date "+%s")
        MYSQL_USER_PASSWORD=$( $MYSQL_COMMAND -rsNe "select substring( password(CONCAT(NOW(),'$TMP_USER_PASSWORD')),2,16 );")
        MYSQL_IS_CONNECTED=$?
        # If connected to SQL, let's go
        if [ 0 -eq $MYSQL_IS_CONNECTED ] ; then 
            MYSQL_DB_NAME="acme_${SUFFIX}"
            MYSQL_USER_NAME="acme_${SUFFIX}"
            $MYSQL_COMMAND -se "CREATE DATABASE ${MYSQL_DB_NAME}"
            $MYSQL_COMMAND -se "CREATE USER '${MYSQL_USER_NAME}'@'localhost' IDENTIFIED BY '${MYSQL_USER_PASSWORD}'"
            $MYSQL_COMMAND -se "GRANT ALL ON ${MYSQL_DB_NAME}.* TO '${MYSQL_USER_NAME}'@'localhost'"
            $MYSQL_COMMAND -se "FLUSH PRIVILEGES"
            $MYSQL_COMMAND "$MYSQL_DB_NAME" < "${APP_PATH}/vendor/octopuce/acmephpc/acmephp.mysql.sql"
            MYSQL_DSN="mysql://${MYSQL_USER_NAME}:${MYSQL_USER_PASSWORD}@localhost/${MYSQL_DB_NAME}"
            echo "Mysql configured : '$MYSQL_DSN'"
            MYSQL_IS_CONFIGURED=1
        else
            echo "Failed to connect to the mysql server, skipping the automatical setup."
        fi

    fi
else
    echo "Can't connect to mysqladmin. You need to handle the database yourself"
fi

# Is the configuration file ready 
if ! file_exists "${APP_PATH}/config.yml" ; then 

    echo "Generating a config file for you"
    cp "${APP_PATH}/config.yml"{.dist,}
    EDITOR=`bin_path editor`
    EDITOR=${EDITOR:-/usr/bin/nano}
    read -e -i "N" -p "Would you like to edit the config file manually using ${EDITOR}? [y/N]: " EDIT_CONFIG
    if option_enabled EDIT_CONFIG; then 
        # We run a special PHP script able to read / write YAML
        $EDITOR "${APP_PATH}/config.yml"
    fi


    # Do we patch the configuration file with mysql values?
    if option_enabled MYSQL_IS_CONFIGURED ; then 
        read -e -i "Y" -p "Would you like to patch the config file automatically with database params? [y/N]: " PATCH_CONFIG 
        if option_enabled PATCH_CONFIG ; then 
            PATCH_CONFIG_RES=` echo $( bin_path php ) "${APP_PATH}/patch_yaml/patch_yaml.php" "${APP_PATH}/config.yml" "$MYSQL_DB_NAME" "$MYSQL_USER_NAME" "$MYSQL_USER_PASSWORD"`
            echo $PATCH_CONFIG_RES
        fi
    fi
fi

# Create a local copy of our binary
ln -s "${APP_PATH}/letsencrypt.php" "/usr/local/bin/letsencrypt"

echo "Installation complete"

exit_function
