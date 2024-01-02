<?php
header('Content-Type: application/json');
include('db_connection.php');

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if 'id' is set in the $_POST array
    if (isset($_POST['id'])) {
        $id = $_POST['id'];

        if (empty($id)) {
            $response['success'] = false;
            $response['message'] = 'ID is required for deleting todo';
        } else {
            $selectQuery = "SELECT * FROM todos WHERE id='$id'";
            $result = mysqli_query($conn, $selectQuery);

            if ($result && $row = mysqli_fetch_assoc($result)) {
                $todo = $row;

                $deleteQuery = "DELETE FROM todos WHERE id='$id'";
                if (mysqli_query($conn, $deleteQuery)) {
                    $response['success'] = true;
                    $response['message'] = 'Todo deleted successfully';
                    $response['todo'] = $todo;
                } else {
                    $response['success'] = false;
                    $response['message'] = 'Error deleting todo: ' . mysqli_error($conn);
                }
            } else {
                $response['success'] = false;
                $response['message'] = 'Todo not found';
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
