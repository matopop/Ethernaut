# 1. Metamask

- Installation de Metamask et mise en place d'un wallet sur le réseau Rinkeby

# 2. Ouverture de la console du navigateur

- Tools -> Developer Tools

- Trouver la console, puis y marquer `player` et exécuter. Cela nous donne notre adresse Ethereum.

- Ecrire `await getBalance(player)` pour obtenir la balance de notre wallet.

###### _**`await`**_ en javascript permet de retourner le retour d'une promesse. Ici, au lieu d'avoir un objet contenant l'état de la promesse ainsi que la valeur de retour, on obtient directement la valeur retournée.

- Ecrire `help()`pour obtenir toutes les fonctions de la console.

# 4. Contrat Ethernaut

- Ecrire `ethernaut` dans la console pour avoir accès au smart contract du jeu.

# 5. Intéragir avec l'ABI

En écrivant `await ethernaut.owner()` on a accès à l'adresse de l'owner du contrat.

En effet, ethernaut est un objet TruffleContract qui contient le contrat Ethernaut.sol qui a été déployé sur la blockchain.

# 6. Recevoir des ether de test

- Faucet : https://faucets.chain.link/rinkeby

# 7. Créer une instance de niveau

Cliquer sur le bouton bleu Get New Instance pour générer une nouvelle instance de niveau. Cela va ensuite ouvrir un pop up metamask qui demande de signer une transaction.
Ca va déployer un nouveau contrat sur la blockchain.

# 8. Inspection du contrat

Tout comme on l'a fait avec la commande `ethernaut`, on peut inspecter notre nouveau contrat en écrivant `contract`

# 9. Intéraction avec le contrat

On va donc jouer avec le contrat depuis la console..
Le jeu va nous balader en nous faisant appeler plusieurs fonctions du contrat telles que contract.info() qui nous dit d'aller voir info1(), puis info1() qui nous dit d'aller voir info2("hello")..

Jusqu'à ce qu'on arrive à faire contract.method7123949() qui nous dit de trouver le mot de passe que l'on trouvera en faisant contract.password().

Puis on entrera ce mot de passe en tant que paramètre dans contract.authenticate().

Ensuite, on devra signer une transaction.
