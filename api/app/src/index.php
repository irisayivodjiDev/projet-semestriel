<?php

use App\Lib\Http\Request;
use App\Lib\Http\Router;

require_once __DIR__ . '/../vendor/autoload.php';

// CORS : autoriser les frontends locaux de développement
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$defaultOrigin = $_ENV['CORS_ORIGIN'] ?? 'http://localhost:5173';

if ($origin !== '' && preg_match('#^https?://(localhost|127\.0\.0\.1)(:\d+)?$#', $origin)) {
    $corsOrigin = $origin;
} else {
    $corsOrigin = $defaultOrigin;
}

header('Access-Control-Allow-Origin: ' . $corsOrigin);
header('Vary: Origin');
header('Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Max-Age: 86400');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

try {
    
    $request = new Request();
    $response = Router::route($request);

    foreach ($response->getHeaders() as $name => $value) {
        header("$name: $value");
    }
    http_response_code($response->getStatus());
    echo $response->getContent();
    exit();
} catch(\Exception $e) {
    $pageNotFoundController = new \App\Controllers\Errors\PageNotFoundController();
    $response = $pageNotFoundController->process(new Request());
    foreach ($response->getHeaders() as $name => $value) {
        header("$name: $value");
    }
    http_response_code(404);
    echo $response->getContent();
    exit();
}
