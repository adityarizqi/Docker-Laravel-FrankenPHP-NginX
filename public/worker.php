<?php

$_SERVER['APP_BASE_PATH'] = $_ENV['APP_BASE_PATH'] ?? $_SERVER['APP_BASE_PATH'] ?? __DIR__.'/..';
$_SERVER['APP_PUBLIC_PATH'] = $_ENV['APP_PUBLIC_PATH'] ?? $_SERVER['APP_BASE_PATH'] ?? __DIR__;

// Make sure you have installed Laravel Octane
require __DIR__.'/../vendor/laravel/octane/bin/frankenphp-worker.php';
