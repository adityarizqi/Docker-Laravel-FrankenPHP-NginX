<?php

// Clear any predefined values
unset(
    $_SERVER['APP_BASE_PATH'],
    $_SERVER['APP_PUBLIC_PATH']
);
unset(
    $_ENV['APP_BASE_PATH'],
    $_ENV['APP_PUBLIC_PATH']
);
putenv('APP_BASE_PATH');
putenv('APP_PUBLIC_PATH');

// Stub the Octane worker to avoid loading a dependency.
$stub = __DIR__ . '/../vendor/laravel/octane/bin/frankenphp-worker.php';
$needsCleanup = !file_exists($stub);
if ($needsCleanup) {
    mkdir(dirname($stub), 0755, true);
    file_put_contents($stub, "<?php\n");
}

// Require the worker to set the paths.
require __DIR__ . '/../public/worker.php';

// Clean up any stub files/directories that were created.
if ($needsCleanup) {
    unlink($stub);
    @rmdir(dirname($stub));
    @rmdir(dirname(dirname($stub)));
    @rmdir(dirname(dirname(dirname($stub))));
}

// Compute expected paths.
$expectedBase = realpath(dirname(__DIR__));
$expectedPublic = realpath(dirname(__DIR__) . '/public');

// Assertions.
if (realpath($_SERVER['APP_BASE_PATH']) !== $expectedBase) {
    throw new RuntimeException('APP_BASE_PATH was not set to the expected default.');
}

if (realpath($_SERVER['APP_PUBLIC_PATH']) !== $expectedPublic) {
    throw new RuntimeException('APP_PUBLIC_PATH was not set to the expected default.');
}

echo "Worker path defaults are correctly set.\n";
