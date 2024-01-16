// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ArtGallery is ERC721 {
    address public owner;
    uint256 public totalArtworks;

    struct Artwork {
        string title;
        string artist;
        string description;
        string imageURI;
        uint256 price;
        bool isForSale;     // Indica si está a la venta
        bool isForAuction;  // Indica si está en subasta
        address auctioner;  // Indica quién es el mayor pujador
        uint256 currentBid; // Indica la puja actual
    }

    mapping(uint256 => Artwork) public artworks;

// Eventos para la compra y creación
    event ArtworkCreated(uint256 indexed tokenId, string title, string artist);
    event ArtworkSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

// Eventos para la subasta
    event ArtworkAuctionCreated(uint256 indexed tokenId, string title, uint256 minBid);
    event ArtworkAuctionBid(uint256 indexed tokenId, string title, address indexed buyer, uint256 bid);
    event ArtworkAuctionEnd(uint256 indexed tokenId, string title, address indexed buyer, uint256 bid);
    event ArtworkAuctionCancelled(uint256 indexed tokenId, string title);

    constructor() ERC721("Artwork", "ART") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function createArtwork(
        string memory _title,
        string memory _artist,
        string memory _description,
        string memory _imageURI,
        uint256 _price
    ) public onlyOwner {
        totalArtworks++;

        uint256 tokenId = totalArtworks;
        _mint(msg.sender, tokenId);

        Artwork memory newArtwork = Artwork({
            title: _title,
            artist: _artist,
            description: _description,
            imageURI: _imageURI,
            price: _price,
            isForSale: false,
            isForAuction: false,
            auctioner: msg.sender,
            currentBid: 0
        });

        artworks[tokenId] = newArtwork;

        emit ArtworkCreated(tokenId, _title, _artist);
    }

// Función para poner una Obra de Arte a la venta
    function putArtworkForSale(uint256 _tokenId, uint256 _price) public {
        // Solo el dueño puede poner a la venta
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this artwork");
        // Se comprueba si ya estuviera a la venta
        require(artworks[_tokenId].isForSale == false, "The artwork is currently on sale");
        // Se comprueba si no está en subasta
        require(artworks[_tokenId].isForAuction == false, "The artwork is currently on auction");
        
        // Se marca que está a la venta
        artworks[_tokenId].isForSale = true;
        // Se graba el precio de venta
        artworks[_tokenId].price = _price;
    }

// Función para comprar una Obra de Arte
    function buyArtwork(uint256 _tokenId) public payable {
        // Se comprueba si está a la venta
        require(artworks[_tokenId].isForSale, "This artwork is not for sale");
        // Se comprueba que se está comprando por el precio justo
        require(msg.value >= artworks[_tokenId].price, "Insufficient funds");

        address payable seller = payable(ownerOf(_tokenId));
        address buyer = msg.sender;
        uint256 price = artworks[_tokenId].price;

        // Se transfiere la propiedad de la Obra de Arte al del comprador
        _transfer(seller, buyer, _tokenId);
        // La Obra de Arte deja de estar a la venta
        artworks[_tokenId].isForSale = false;

        // El anterior dueño recibe el pago
        seller.transfer(price);

        emit ArtworkSold(_tokenId, buyer, price);
    }

// Función para consultar si una Obra de Arte está a la venta
    function isArtworkOnSale(uint256 _tokenId) public view returns (bool){
        return artworks[_tokenId].isForSale;
    }

// Función para poner una Obra de Arte a subasta
    function putArtworkForAuction(uint256 _tokenId, uint256 _price) public {
        // Solo el dueño de la Obra de Arte puede ponerlo a subasta
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this artwork");
        // No se puede poner a subasta si ya está a la venta
        require(artworks[_tokenId].isForSale == false, "The artwork is currently on sale");
        // Se comprueba si no estuviera ya en subasta
        require(artworks[_tokenId].isForAuction == false, "The artwork is currently on auction");

        // Se marca que está en subasta
        artworks[_tokenId].isForAuction = true;
        // Para control, el pujador actual es el dueño de la obra
        artworks[_tokenId].auctioner = msg.sender;
        // Se indica la puja inicial
        artworks[_tokenId].currentBid = _price;

        emit ArtworkAuctionCreated(_tokenId, artworks[_tokenId].title, _price);
    }

// Función para pujar por una Obra de Arte
    function bidArtwork(uint256 _tokenId) public payable{
        // La Obra de Arte debe de estar en subasta
        require(artworks[_tokenId].isForAuction == true, "The artwork is not on auction");
        // Por control, el dueño no puede pujar por su propia Obra
        require(ownerOf(_tokenId) != msg.sender, "Can't bid for owned artwork");
        // Se comprueba que la puja es mayor que la actual
        require(artworks[_tokenId].currentBid < msg.value, "Low bid");

        // En caso de no ser la primera puja (al principio se fija como actual pujante al dueño), se devuelve la puja anterior
        if (ownerOf(_tokenId) != artworks[_tokenId].auctioner) {
            payable(artworks[_tokenId].auctioner).transfer(artworks[_tokenId].currentBid);
        }
        
        // Se marca el nuevo pujante
        artworks[_tokenId].auctioner = msg.sender;
        // Actualiza la última puja
        artworks[_tokenId].currentBid = msg.value;

        emit ArtworkAuctionBid(_tokenId, artworks[_tokenId].title, msg.sender, msg.value);
    }

// Función para terminar una subasta de una Obra de Arte
    function endArtworkAuction(uint256 _tokenId) public{
        // Solo el dueño puede terminar la subasta
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this artwork");
        // Se comprueba si está en subasta
        require(artworks[_tokenId].isForAuction == true, "The artwork is not on auction");

        // Se comprueba si hay pujas reales (el primer pujante siempre es el dueño)
        if (artworks[_tokenId].auctioner != msg.sender){
            // Se paga al dueño anterior la puja actual
            payable(ownerOf(_tokenId)).transfer(artworks[_tokenId].currentBid);
            // La Obra de Arte pasa a ser de la propiedad del mayor pujante
            _transfer(ownerOf(_tokenId), artworks[_tokenId].auctioner, _tokenId); 

            emit ArtworkAuctionEnd(_tokenId, artworks[_tokenId].title, msg.sender, artworks[_tokenId].currentBid);
        }else {
            // En caso de no haber pujas (el pujante actual es el dueño), se cancela la subasta
            emit ArtworkAuctionCancelled(_tokenId, artworks[_tokenId].title);
        }
        // La Obra de Arte ya no está en subasta
        artworks[_tokenId].isForAuction = false;
        // Se reinicia la puja actual
        artworks[_tokenId].currentBid = 0;      
    }

// Función para consultar si una Obra de Arte está en subasta
    function isArtworkOnAuction(uint256 _tokenId) public view returns (bool){
        return artworks[_tokenId].isForAuction;
    }

// Función para consultar la identidad del mayor pujante
    function maxArtworkAuctioner(uint256 _tokenId) public view returns (address){
        return artworks[_tokenId].auctioner;
    }

// Función para consultar la mayor puja
    function currentArtworkBid(uint256 _tokenId) public view returns (uint256){
        return artworks[_tokenId].currentBid;
    }


}
