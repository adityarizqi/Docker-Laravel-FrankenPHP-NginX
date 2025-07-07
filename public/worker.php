<?php

$_ENV['APP_ENV'] = 'production';
$_ENV['APP_BASE_PATH'] = __DIR__ . '/..';
$_ENV['APP_PUBLIC_PATH'] = __DIR__;
$_ENV['LARAVEL_OCTANE'] = 1;
$_ENV['MAX_REQUESTS'] = 1000;
$_ENV['REQUEST_MAX_EXECUTION_TIME'] = 30;

// Make sure you have installed Laravel Octane
require __DIR__.'/../vendor/laravel/octane/bin/frankenphp-worker.php';
