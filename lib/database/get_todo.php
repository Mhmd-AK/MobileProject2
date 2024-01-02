<?php
header('Content-Type: application/json');
include('db_connection.php');

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $query = "SELECT * FROM todos";
    $result = mysqli_query($conn, $query);

    if ($result) {
        $todos = array();
        while ($row = mysqli_fetch_assoc($result)) {
            $todos[] = $row;
        }

        $response['success'] = true;
        $response['message'] = 'Todo fetched successfully';
        $response['todos'] = $todos;
    } else {
        $response['success'] = false;
        $response['message'] = 'Error fetching todos: ' . mysqli_error($conn);
    }
} else {
    $response['success'] = false;
    $response['message'] = 'Invalid request method';
}

echo json_encode($response);
?>
