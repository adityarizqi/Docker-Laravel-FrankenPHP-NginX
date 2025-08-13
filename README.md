## Laravel Octane Docker Setup (with FrankenPHP)
### How It Works
This setup provides a ready-to-use Docker environment optimized for Laravel Octane with FrankenPHP. It is designed for both local development and production builds, including automatic HTTPS using mkcert.

To use it:
- Copy all files and folders from this repository into the root of your existing Laravel project.
- Follow the steps below to set up Docker, generate SSL certificates, and start your Laravel Octane app in seconds.

## Docker Setup Guide

### Step 1: Copy to your Laravel Project
- Go to the [Releases page](https://github.com/adityarizqi/Docker-Laravel-FrankenPHP-NginX/releases)  
- Download the **`Source code (zip)`** from this release.  
- Extract the contents into the root folder of your existing Laravel project.
  
> **Tip:** If you are on Windows, I recommend using WSL2, or at least utilize Git Bash instead of CMD or PowerShell to execute the next commands along.

### Step 2: Download mkcert

Download [mkcert](https://github.com/FiloSottile/mkcert), a tool for generating self-signed SSL certificates. Get the binary from the [release](https://github.com/FiloSottile/mkcert/releases) page.

> **Note**: This is a one-time setup, and you can reuse the generated certificates for any subsequent projects on the same machine.

Execute the following command in your terminal after obtaining the mkcert binary:

```shell
mkcert -install -cert-file ./docker/nginx/ssl/cert.pem -key-file ./docker/nginx/ssl/key.pem "*.docker.localhost" docker.localhost
```

> **Note**: If you plan to use other domains, simply replace `docker.localhost` with the desired domain. You can add multiple domains to the list as needed. Keep in mind that any domain not ending in `.localhost` will require a manual edit of the hosts file.

> **Note**: If you are on Windows using WSL2, you have to run this command on the Windows side. This is because mkcert needs to install the certificates in your Windows trust store, not on Linux.

### Step 3: Start the Containers

-   Build the images and start the containers:

    - **Development**:

      ```shell
      docker-compose -f docker-compose.development.yml up -d
      ```

    - **Production**:

      ```shell
      docker-compose -f docker-compose.production.yml up -d
      ```

> **Note**: Make sure you have installed the SSL certificates before proceeding.

Make necessary scripts executable:

```shell
chmod +x ./php ./composer ./npm
```

Install dependencies and prepare framework:

```shell
./composer install
./npm install
./npm run dev
./php artisan key:generate
./php artisan migrate:fresh --seed
```

> **Note**: The `./` at the beginning of each command is an alias to `docker compose -f docker-compose.development.yml exec php`, allowing you to run commands within the container without entering it.

You're done! Open https://laravel.docker.localhost to view the application.

> **Tip**: `./npm run dev` starts Vite's hot-reload server. For a production-ready asset build, use `./npm run build` instead.
