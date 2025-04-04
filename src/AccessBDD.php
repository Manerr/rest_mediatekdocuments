<?php
include_once("ConnexionPDO.php");

/**
 * Classe de construction des requêtes SQL à envoyer à la BDD
 */
class AccessBDD {
	
    public $login="root";
    public $mdp="Azerty85";
    public $bd="mediatek86";
    public $serveur="127.0.0.1";
    public $port="3306";	
    public $conn = null;
	
   #public $login="root";
   #public $mdp="Azerty85!";
   #public $bd="mediatekdocuments";
   #public $serveur="localhost";
   #public $port="3306";	
   #public $conn = null;

    /**
     * constructeur : demande de connexion à la BDD
     */
    public function __construct(){
        try{
            $this->conn = new ConnexionPDO($this->login, $this->mdp, $this->bd, $this->serveur, $this->port);
        }catch(Exception $e){
            echo $e;
            throw $e;
        }
    }

    /**
     * récupération de toutes les lignes d'une table
     * @param string $table nom de la table
     * @return lignes de la requete
     */
    public function selectAll($table){

        if($this->conn != null){
            switch ($table) {
                case "livre" :
                    return $this->selectAllLivres();
                case "dvd" :
                    return $this->selectAllDvd();
                case "revue" :
                    return $this->selectAllRevues();
                case "exemplaire" :
                    return $this->selectAllExemplairesRevue();
                case "commandedocument" :
                    return $this->selectAllCommandesDocument();
                case "abonnementsecheance" :
                    return $this->selectAllAbonnementsEcheance();
                default:
                    // cas d'un select portant sur une table simple, avec tri sur le libellé
                    return $this->selectAllTableSimple($table);
            }			
        }else{
            return null;
        }
    }

    /**
     * récupération d'une ligne d'une table
     * @param string $table nom de la table
     * @param string $id id de la ligne à récupérer
     * @return ligne de la requete correspondant à l'id
     */	
    public function selectOne($table, $id){
        if($this->conn != null){
            switch($table){
                case "exemplaire" :
                    return $this->selectAllExemplairesRevue($id);
                case "dvd" :
                    return $this->selectAllDvd($id);
                case "revue" :
                    return $this->selectAllRevues($id);
                case "commandedocument" :
                    return $this->selectAllCommandesDocument($id);
                case "abonnement" :
                    return $this->selectAllAbonnementsRevues($id);
                case "exemplairesdocument":
                    return $this->selectAllExemplairesDocument($id);
                case "utilisateur":
                    return $this->selectUtilisateur($id);
                default:
                    // cas d'un select portant sur une table simple			
                    $param = array(
                        "id" => $id
                    );
                    return $this->conn->query("select * from $table where id=:id;", $param);					
            }				
        }else{
                return null;
        }
    }
   
    /**
     * récupération de toutes les lignes de d'une table simple (sans jointure) avec tri sur le libellé
     * @param type $table
     * @return lignes de la requete
     */
    public function selectAllTableSimple($table){
        $req = "select * from $table order by libelle;";		
        return $this->conn->queryAll($req);		
    }

    /**
     * récupération de toutes les lignes de la table Livre et les tables associées
     * @return lignes de la requete
     */
    public function selectAllLivres(){
        $req = "select l.id, l.ISBN, l.auteur, d.titre, d.image, l.collection, ";
        $req .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $req .= "from livre l join document d on l.id=d.id ";
        $req .= "join genre g on g.id=d.idGenre ";
        $req .= "join public p on p.id=d.idPublic ";
        $req .= "join rayon r on r.id=d.idRayon ";
        $req .= "order by titre ";		
        return $this->conn->queryAll($req);
    }	

    /**
     * récupération de toutes les lignes de la table DVD et les tables associées
     * @return lignes de la requete
     */
    public function selectAllDvd(){
        $req = "select l.id, l.duree, l.realisateur, d.titre, d.image, l.synopsis, ";
        $req .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $req .= "from dvd l join document d on l.id=d.id ";
        $req .= "join genre g on g.id=d.idGenre ";
        $req .= "join public p on p.id=d.idPublic ";
        $req .= "join rayon r on r.id=d.idRayon ";
        $req .= "order by titre ";	
        return $this->conn->queryAll($req);
    }	

    /**
     * récupération de toutes les lignes de la table Revue et les tables associées
     * @return lignes de la requete
     */
    public function selectAllRevues(){
        $req = "select l.id, l.periodicite, d.titre, d.image, l.delaiMiseADispo, ";
        $req .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $req .= "from revue l join document d on l.id=d.id ";
        $req .= "join genre g on g.id=d.idGenre ";
        $req .= "join public p on p.id=d.idPublic ";
        $req .= "join rayon r on r.id=d.idRayon ";
        $req .= "order by titre ";
        return $this->conn->queryAll($req);
    }	

    public function selectAllExemplairesRevue($id){
        $param = array(
                "id" => $id
        );
        $req = "select e.id, e.numero, e.dateAchat, e.photo, e.idEtat ";
        $req .= "from exemplaire e join document d on e.id=d.id ";
        $req .= "where e.id =:id ";
        $req .= "order by e.dateAchat DESC";		
        return $this->conn->queryAll($req, $param);
    }
    

    public function selectAllCommandesDocument($id) {
        $param = array (
            "id" => $id
                );
        $req = "select l.nbExemplaire, l.idLivreDvd, l.idSuivi, s.libelle, l.id, max(c.dateCommande) as dateCommande, sum(c.montant) as montant ";
        $req .= "from commandedocument l join suivi s on s.id=l.idSuivi ";
        $req .= "left join commande c on l.id=c.id ";
        $req .= "where l.idLivreDvd = :id ";
        $req .= "group by l.id ";
        $req .= "order by dateCommande DESC";
        return $this->conn->query($req, $param);
    }
    
    
    public function selectAllAbonnementsRevues($id){
        $param = array(
                "id" => $id
        );
        $req = "select c.id, c.dateCommande, c.montant, a.dateFinAbonnement, a.idRevue  ";
        $req .= "from commande c join abonnement a ON c.id=a.id ";
        $req .= "where a.idRevue= :id  ";
        $req .= "order by c.dateCommande DESC  ";
        return $this->conn->queryAll($req, $param);
    }

    
    public function selectAllAbonnementsEcheance(){


        $req ="select a.dateFinAbonnement, a.idRevue, d.titre ";
        $req .="from abonnement a ";
        $req .="join revue r on a.idRevue = r.id ";
        $req .="join document d on r.id = d.id ";
        $req .="where datediff(current_date(), a.dateFinAbonnement) < 30 ";
        $req .="order by a.dateFinAbonnement ASC; ";


        return $this->conn->queryAll($req);
    }   
    
    
    public function selectAllExemplairesDocument($id){
    $param = array(
                "id" => $id
        );
        $req = "select ex.id, ex.numero, ex.dateAchat, ex.photo, ex.idEtat, et.libelle ";
        $req .= "from exemplaire ex JOIN etat et ON ex.idEtat = et.id ";
        $req .= "where ex.id = :id ";
        $req .= "order by ex.dateAchat DESC";       
        return $this->conn->query($req, $param);
    }
    
    
    public function selectUtilisateur($id)
    {
        $param = array(
                "id" => $id
                
        );
        $req = "select u.login, u.password , u.idService, s.libelle  ";
        $req .= "from utilisateur u  join service s on s.id=u.idService ";
        $req .= "where u.login =:id  ";     
        return $this->conn->queryAll($req, $param);
    }   

    /**
     * suppresion d'une ou plusieurs lignes dans une table
     * @param string $table nom de la table
     * @param array $champs nom et valeur de chaque champs
     * @return true si la suppression a fonctionné
     */	
    public function delete($table, $champs){
        if($this->conn != null){
            // construction de la requête
            $requete = "delete from $table where ";
            foreach ($champs as $key => $value){
                $requete .= "$key=:$key and ";
            }
            // (enlève le dernier and)
            $requete = substr($requete, 0, strlen($requete)-5);   
            return $this->conn->execute($requete, $champs);		
        }else{
            return null;
        }
    }
    
    /**
     * ajout d'une ligne dans une table
     * @param string $table nom de la table
     * @param array $champs nom et valeur de chaque champs de la ligne
     * @return true si l'ajout a fonctionné
     */	
    public function insertOne($table, $champs){
        if($this->conn != null && $champs != null){
            // construction de la requête
            $requete = "insert into $table (";
            foreach ($champs as $key => $value){
                $requete .= "$key,";
            }
            // (enlève la dernière virgule)
            $requete = substr($requete, 0, strlen($requete)-1);
            $requete .= ") values (";
            foreach ($champs as $key => $value){
                $requete .= ":$key,";
            }
            // (enlève la dernière virgule)
            $requete = substr($requete, 0, strlen($requete)-1);
            $requete .= ");";	
            return $this->conn->execute($requete, $champs);		
        }else{
            return null;
        }
    }

    /**
    * Modifie une ligne dans une table
    * prise en compte du numéro d'exemplaire spécifique
    * @param string $table nom de la table
    * @param string $id id de la ligne à modifier
    * @param array $champs nom et valeur de chaque champ de la ligne
    * @return true si la modification a fonctionné
    */ 
    public function updateOne($table, $id, $champs){



        if($this->conn != null && $champs != null){
            switch($table){
                case "exemplairesdocument":
                case "exemplaire":
                    $champsExemplaire = [
                        'id' => $champs['Id'],
                        'numero' => $champs['Numero'],
                        'dateAchat' => $champs['DateAchat'],
                        'photo' => $champs['Photo'],
                        'idEtat' => $champs['IdEtat']
                    ];

                    // var_dump($champsExemplaire);

                    $requete = "UPDATE exemplaire SET ";
                    foreach ($champsExemplaire as $key => $value) {
                        $requete .= "$key=:$key,";
                    }
                    $requete = substr($requete, 0, strlen($requete)-1);
                    $requete .= " WHERE id=:id AND numero=:numero;";


                    $champsExemplaire['numero'] = $id;
                    $updateExemplaire = $this->conn->execute($requete, $champsExemplaire);   
                    // var_dump($updateExemplaire);
                    if(!$updateExemplaire){
                        return null;
                    }
                    return $updateExemplaire;
                    break;

                case "exemplaire":

                default:
                
                    $champs['id'] = $id;
                    $requete = "UPDATE $table SET ";
                    foreach ($champs as $key => $value) {
                        $requete .= "$key=:$key,";
                    }
                    $requete = substr($requete, 0, strlen($requete)-1);
                    $requete .= " WHERE id=:id;";

                    $rek = $this->conn->execute($requete, $champs);
                    return $rek;                 
            }
        }
        else
        {
            return null;
        }
    }

}
