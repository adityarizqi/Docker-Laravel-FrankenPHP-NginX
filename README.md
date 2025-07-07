# Docker Setup Guide

### Step 1: Clone the Project

Clone this repository and navigate into it. If you are on Windows, I recommend using WSL2, or at least utilize Git Bash instead of CMD or PowerShell to execute the next commands along.

### Step 2: Download mkcert

Download [mkcert](https://github.com/FiloSottile/mkcert), a tool for generating self-signed SSL certificates. Get the binary from the [release](https://github.com/FiloSottile/mkcert/releases) page.

> **Note**: This is a one-time setup, and you can reuse the generated certificates for any subsequent projects on the same machine.

Execute the following command in your terminal after obtaining the mkcert binary:

```shell
mkcert -install -cert-file ./docker/nginx/ssl/cert.pem -key-file ./docker/nginx/ssl/key.pem "*.docker.localhost" docker.localhost
```

> **Note**: If you plan to use other domains, simply replace `docker.localhost` with the desired domain. You can add multiple domains to the list as needed. Keep in mind that any domain not ending in `.localhost` will require a manual edit of the hosts file.

> **Note**: If you are on Windows using WSL2, you have to run this command on the Windows side. This is because mkcert needs to install the certificates in your Windows trust store, not on Linux.

### Step 3: Environment Setup

-   Copy the `.env.example` file to `.env`

-   Configure your environment. For development ensure that the `APP_DOMAIN` variable is set to `panel.docker.localhost` and APP_CRM_DOMAIN set to `crm.docker.localhost`
    > **Note**: Make sure you have installed the SSL certificates before proceeding.

### Step 4: Start the Containers

-   Build the images and start the containers with:

```shell
docker-compose up -d
```

Make necessary scripts executable:

```shell
chmod +x ./php ./composer ./npm ./production.sh ./setup.sh
```

Install dependencies and prepare framework:

```shell
./composer install
./npm install
./npm run build
./php artisan key:generate
./php artisan migrate:fresh --seed
```

> **Note**: The `./` at the beginning of each command is an alias to `docker compose exec php`, allowing you to run commands within the container without entering it.

You're done! Open https://panel.docker.localhost to view application.
