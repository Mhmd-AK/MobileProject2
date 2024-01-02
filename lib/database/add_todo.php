<?php
header('Content-Type: application/json');
include('db_connection.php');

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $todoText = $_POST['todoText'];
    $isDone = $_POST['isDone'];

    $query = "INSERT INTO todos (todoText, isDone) VALUES ('$todoText', '$isDone')";

    if (mysqli_query($conn, $query)) {
        $todoId = mysqli_insert_id($conn);
        $response['success'] = true;
        $response['message'] = 'Todo added successfully';
                $response['todo'] = array('id' => (string)$todoId, 'todoText' => $todoText, 'isDone' => $isDone);

    } else {
        $response['success'] = false;
        $response['message'] = 'Error adding todo: ' . mysqli_error($conn);
    }
} else {
    $response['success'] = false;
    $response['message'] = 'Invalid request method';
}

echo json_encode($response);
?>
