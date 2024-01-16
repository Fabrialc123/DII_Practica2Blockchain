# DII_Practica2Blockchain

Componentes del Contrato
Herencia de ERC721 y Ownable:
ERC721: Es un estándar para crear NFTs. Cada token NFT es único y puede ser transferido entre cuentas
Ownable: Proporciona funciones básicas de control de acceso, asignando un "propietario" al contrato, que tiene permisos exclusivos para realizar ciertas operaciones.
Variables de Estado:
tokenIdCounter: Lleva la cuenta del número de tokens que han sido acuñados.
tokenURIs: Mapea cada tokenId a su respectiva URI (Uniform Resource Identifier), que usualmente enlaza a metadatos del NFT.
tokenPrices: Mapea cada tokenId a su precio, para uso en la venta de NFTs.
tokensForSale: Mapea qué tokens están actualmente en venta.
Eventos:
TokenListedForSale: Se emite cuando un token es puesto en venta.
TokensPurchased: Se emite cuando un token es comprado.
Constructor:
Inicializa el contrato con un nombre y un símbolo para la colección de NFTs y establece al creador del contrato como el propietario inicial.
Funciones Principales:
mint: Permite al propietario del contrato acuñar un nuevo NFT.
_setTokenURI: Asigna una URI a un token específico.
tokenURI: Devuelve la URI asociada con un token específico.
setTokenPrice: Establece el precio de un token.
listTokenForSale: Lista un token para la venta.
purchaseToken: Permite a un usuario comprar un token.
_exists: Verifica internamente si un token específico existe.
Funcionamiento General
Acuñación de NFTs: El propietario del contrato puede crear nuevos NFTs llamando a mint. Cada NFT tiene una URI única que generalmente enlaza a un archivo JSON con detalles sobre el NFT (como imagen, descripción, etc.).
Venta de NFTs: El propietario de un NFT puede listar su token para la venta a un precio específico. Otros usuarios pueden comprar estos tokens enviando la cantidad correcta de ETH.
Transferencia de Propiedad y Pago: Cuando un token se vende, la propiedad del token se transfiere al comprador, y el ETH enviado se transfiere al vendedor.

Esta fue la pagina que use para guiarme https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
