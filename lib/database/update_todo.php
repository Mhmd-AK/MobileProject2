<?php
header('Content-Type: application/json');
include('db_connection.php');

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if 'id' is set in the $_POST array
    if (isset($_POST['id'])) {
        $id = $_POST['id'];
        $todoText = isset($_POST['todoText']) ? $_POST['todoText'] : '';
        $isDone = isset($_POST['isDone']) ? $_POST['isDone'] : '';

        if (empty($id)) {
            $response['success'] = false;
            $response['message'] = 'ID is required for updating todo';
        } else {
            $query = "UPDATE todos SET todoText='$todoText', isDone='$isDone' WHERE id='$id'";

            if (mysqli_query($conn, $query)) {
                $response['success'] = true;
                $response['message'] = 'Todo updated successfully';
                $response['todo'] = array('id' => (string)$id, 'todoText' => $todoText, 'isDone' => $isDone);

              //  $response['todo'] = array('id' => $id, 'todoText' => $todoText, 'isDone' => $isDone);
            } else {
                $response['success'] = false;
                $response['message'] = 'Error updating todo: ' . mysqli_error($conn);
            }
        }
    } else {
        $response['success'] = false;
        $response['message'] = 'ID is not set in the request';
    }
} else {
    $response['success'] = false;
    $response['message'] = 'Invalid request method';
}

echo json_encode($response);
?>
