<?php
/**
 * Classe de connexion et d'exécution des requêtes dans une BDD MySQL
 */
class ConnexionPDO {

    private $conn = null;

    /**
     * constructeur privé : connexion à la BDD
     * @param string $login 
     * @param string $mdp
     * @param string $bd
     * @param string $serveur
     * @param int $port
     */
    public function __construct($login, $mdp, $bd, $serveur, $port){
        try {
            $this->conn = new PDO("mysql:host=$serveur;dbname=$bd;port=$port", $login);
            $this->conn->query('SET CHARACTER SET utf8');
        } catch (PDOException $e) {
            throw $e;

        }
    }

    /**
     * Exécution d'une requête de mise à jour (insert, update, delete)
     * @param string $requete
     * @param array $param
     * @return résultat requête (booléen)
     */
    public function execute($requete, $param=null){

            // echo $requete;
        
            $requetePrepare = $this->conn->prepare($requete);
            if($param != null){
                foreach ($param as $key => $value) {
                    if (is_int($value)) {
                        $requetePrepare->bindValue(":$key", $value, PDO::PARAM_INT);
                    } elseif (is_bool($value)) {
                        $requetePrepare->bindValue(":$key", $value, PDO::PARAM_BOOL);
                    } elseif (strtotime($value) !== false) { 
                        $requetePrepare->bindValue(":$key", $value, PDO::PARAM_STR);
                    } else {
                        $requetePrepare->bindValue(":$key", $value, PDO::PARAM_STR);
                    }
                }
            }
            // var_dump($requetePrepare);
            $requetePrepare->execute();
            return ($requetePrepare);
        
    }

    /**
     * Exécution d'une requête select retournant plusieurs lignes
     * @param string $requete
     * @param array $param
     * @return lignes récupérées
     */
    public function queryAll($requete, $param=null){
        try{
            $requetePrepare = $this->conn->prepare($requete);
            if($param != null){
                foreach($param as $key => &$value){
                    $requetePrepare->bindParam(":$key", $value);
                }
            }
            $requetePrepare->execute();				
            $result = $requetePrepare->fetchAll(PDO::FETCH_ASSOC);
            if($requetePrepare->rowCount() != 0){
                return $result;
            }else{
                return null;
            }
        }catch(Exception $e){
            return null;
        }		
    }

    /**
     * Exécution d'une requête select retournant 0 à plusieurs lignes
     * @param string $requete
     * @param array $param
     * @return lignes récupérées
     */
    public function query($requete, $param=null){
        try{
            $requetePrepare = $this->conn->prepare($requete);
            if($param != null){
                foreach($param as $key => &$value){
                    $requetePrepare->bindParam(":$key", $value);
                }
            }
            $requetePrepare->execute();				
            return $requetePrepare->fetchAll(PDO::FETCH_ASSOC);
        }catch(Exception $e){
            return null;
        }		
    }
	
}