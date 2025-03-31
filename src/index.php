<?php
header('Content-Type: application/json');
include_once ("Url.php");
include_once("Controle.php");

$controle = new Controle();
$url = Url::getInstance();

if(isset($_GET['error']) && $_GET['error'] == 404){
    header('HTTP/1.0 404 Not Found');
    echo json_encode(array('message' => 'Erreur 404: Page non trouvee'));
    exit();
}

// Contrôle de l'authentification
if (!$url->authentification()){
    // l'authentification a échoué
    $controle->unauthorized();
    
}else{
    



    // récupération des données
    $methodeHTTP = $url->recupMethodeHTTP();
    
    $table = $url->recupVariable("table");
    $id = $url->recupVariable("id");

    $champs = $url->recupVariable("champs", "json");

    $champs = json_decode(file_get_contents("php://input"),true);



    if($methodeHTTP === 'GET'){
        $controle->get($table, $id);
    }else if($methodeHTTP === 'POST'){
        $controle->post($table, $champs);
    }else if($methodeHTTP === 'PUT'){
        $controle->put($table, $id, $champs);
    }else if($methodeHTTP === 'DELETE'){
        $controle->delete($table, $champs);
    }



}