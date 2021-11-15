// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";


contract Disney{
    
    //--------------------------------------DECLARACIONES INICIALES-------------------------------------------------------
    
    //instanciamos el contrato tocken
    ERC20Basic private token;
    
    //direccion de Disney (owner)
    
    address payable public owner;
    
    //constructor
    constructor () public{
        token = new ERC20Basic(10000);
         owner = msg.sender;
    }
    
    // structura de datos para almacenar a los clientes de Disney
    
    struct cliente{
        uint tokens_comprados;
        string [] atracciones_disfrutas;
    }
    
    //mapping para registro de cliente
    mapping (address => cliente) public Clientes;
    
    //--------------------------------------GESTION DE TOCKEN -------------------------------------------------------------
    
    
    //funciona pra establecer el precio de un TOCKEN
    function PrecioTocken(uint _numTocken) internal pure returns(uint){
        //conversion de token a ether ----> 1 tocken --> 1 ether
        return _numTocken * (1 ether);
    }
    
    
    //funcion pra comprar tocken en disney y disfrutar de las actracciones 
    function ComprarTockens(uint _numTockens) public payable {
        //establecer el precio de los tocken
        uint coste = PrecioTocken(_numTockens);
        //se evalue si el cliente tiene dinero 
        require (msg.value >= coste, " compra menos tocker o paga con mas ether.");
        //Diferencia de la el cliente paga
        uint returnValue = msg.value - coste;
        //disney retorna la cantidad de ether el cliente 
        msg.sender.transfer(returnValue);
        //obtener el nro de tocker disponible
        uint Balance = balanceOf();
        require(_numTockens <= Balance, " compra un nro menor de tocken");
        //se tranfiere el nro de token al cliente 
        token.transfer(msg.sender, _numTockens) ;
        //registro de tokens_comprados
        Clientes[msg.sender].tokens_comprados += _numTockens;
        
    }
    //para consultar el balance de token del contrato disney
    function balanceOf() public view returns(uint){
    return token.balanceOf(address(this));
    
    }
    
    //visualizar el nro de token disponible
    function  MisToken() public view returns(uint){
        return token.balanceOf(msg.sender);
    }
    
    //funcion para generar mas  token
    
     function GeneraTokens(uint _numTockens) public Unicamente(msg.sender){
         token.increaseTotalSupply(_numTockens);
     }
    
    //moficadror para controlar la funciones ejecutables por disney
    modifier Unicamente(address _direccion){
        require(_direccion == owner,"no tienes permisos para ejecutar esta funcion");
        _;
    }
    
    //----------------------------------GESTION DE DISNEY--------------------------------------------------
    
    // EVENTOS
    event disfruta_atraccion(string, uint, address);
    event nueva_atracciones(string, uint);
    event baja_atracciones(string);
    
    //structura de datos de la actracciones
    
    struct atraccion{
        string nombre;
        uint precio_atraccion;
        bool estado;
    }
    
    //mapping para relaciones un nombre de atraccion con una structura  de datos de la atraccion
    
    mapping(string => atraccion) public mappingAtracciones;
    
    //array para almacenar el nombre atraccion
    string [] Atracciones;
    
    //mapping para relacionar un clientes con su historia en DISNEY--------------------------------------------------
    mapping(address => string [] ) HistorialAtracciones;
    
    
    //star war -> 2 tokens_comprados
    //toy Story -> 5 tokens_comprados
    //piratas del caribe --> 8 tokens
    
    
    //permite crear nueva atracciones para disney
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender){
        //Creacion de una atraccion en DISNEY--------------------------------------------------
        mappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        //almacenar en una array el nombre de la atraccion
        Atracciones.push(_nombreAtraccion);
        //emitir evento de la nueva atracciones
        emit nueva_atracciones(_nombreAtraccion, _precio);
    }
    
    //dar de baja un atracciones 
    function bajaAtracciones(string memory _nombreAtraccion) public Unicamente (msg.sender){
        //cambiar el estado a false
    mappingAtracciones[_nombreAtraccion].estado = false;
    //emitar evento
    emit baja_atracciones(_nombreAtraccion);
        
    }
    
    //function visualizar las atracciones 
    function verAtracciones()  public view returns(string[] memory ){
        return Atracciones;
        
    }
    
    
    //Funcion para subirse a una Atracciones de DISNEY y pagar en tocken
    
    function SubirseAtraccion (string memory _nombreAtraccion) public{
        //Preci de la atraccion en tokens
        uint tokens_atraccion = mappingAtracciones[_nombreAtraccion].precio_atraccion;
        //verifica el stado de la atraccion(si esta disponible para su uso)
        require (mappingAtracciones[_nombreAtraccion].estado == true, "la atraccion no esta disponible");
        //Verificar el Nro de Tokens que tiene el CLiente para subirse a la atraccion
        require(tokens_atraccion <= MisToken(),"necesitas mas tokens para subirse a la atraccion.");
        
        /* EL ciente paga la atraccion en tokens
        - Fue necesario crear una funcion en ERC20.sol con el nombre transferenciaDisney
        debido a que en caso de usar el tansfer o transferFrom  que se escogian para la transaccion estaba equivocdas
        ya el msg.sender qeu recibia el metodo de transfer y transferFrom recibia la direccion del contrato
        */
        
        token.transferenciaDisney(msg.sender, address(this), tokens_atraccion);
        //almacenar en el historial del cliente 
        HistorialAtracciones[msg.sender].push(_nombreAtraccion);
       // emitir evento para disfruta_atraccion
        emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion, msg.sender);
        
    }
    
    //FUnciona para visualizar el historial completo de una cliente 
    function Historial() public view returns(string [] memory){
        return HistorialAtracciones[msg.sender];
        
    }
    
    //Funcion para que un cliente de disney puede devolver tocken 
    
    function DevolverTokens(uint _numTockens) public payable {
        //Validar el nro de tocken a devolver es positivo
        require(_numTockens > 0, "no tienes tocken para devolver");
        //el usuario debe tener el nro de tocken que desea devolver
        require(_numTockens <= MisToken(), "no tiene esa cantidad de tocken");
        //El cliente devuelve los tokens
         token.transferenciaDisney(msg.sender, address(this), _numTockens);
         //devolucion de los ether al cliente
         msg.sender.transfer(PrecioTocken(_numTockens));
    }
    
    ///////-----------------------COMPRAR COMIDA CON TOKEN---------------//////////////////
    event altaComida (string, uint, address );
    event darBaja (string);
    event comprarComida(string, uint, address);
    
    
    //estructura de datos para la COMIDA  struct atraccion{
       struct comida{
            string nombre_comida;
            uint precio;
            bool estado;
    }
    
    //mapping para relacionar  el nombre de una comida con la su estructura de datos 
     mapping(string => comida) public mappingComida;
    
    
     //array para almacenar los nombre de las comidas
    string [] Comidas;
    
     //mapping para relacionar un clientes con su historia de comidas en Disney
    mapping(address => string [] ) HistorialComida;
    
    
    
    // funcion para dar de alta comida 
    function AltaComida(string memory _nombreComida, uint precio) public Unicamente(msg.sender){
        //dar de Alta a  una nueva Comida 
        mappingComida[_nombreComida] = comida(_nombreComida, precio, true);
        //Almacenamos en un array los nombre de comidas
        Comidas.push(_nombreComida);
        //Emitimos un evento de alta de Comida
        emit  altaComida (_nombreComida, precio, msg.sender);
    }
    
    
     // funcion para dar de Baja Comida 
     function BajaComida(string memory _nombreComida) public Unicamente(msg.sender){
         //Colocamos en false el estado de la Comida
         mappingComida[_nombreComida].estado = false;
         //Emitimos evento de baja de Comida
         emit darBaja(_nombreComida);
     }
     
     //  string [] MenuDishes;
      // string  dish;
     //function para ver el Menu
     function verMenu() public view returns (string[] memory){
         
       /*  for(uint i=0; i < Comidas.length; i++){
              dish = Comidas[i];
            
             if(mappingComida[dish].estado != false) {
                MenuDishes.push(dish);
               }
             
         }*/
         return Comidas;
         
     }
     
    function ComprarComida(string memory _nombreComida) public{
        //Precio de la Comida 
        uint precioComidaToken = mappingComida[_nombreComida].precio;
        //validamos el estado de la Comida
        require (mappingComida[_nombreComida].estado == true, "No tenemo este producto disponible");
        //validar el nro de TOKEN que tiene el cliente para comprar la Comida
        require(precioComidaToken <= MisToken(), "no tienes suficiente token");
        
        //el cliente paga la comiaa
        token.transferenciaDisney(msg.sender, address(this), precioComidaToken);
        // Almacenar el historial de compras de comidas del cliente
        HistorialComida[msg.sender].push(_nombreComida);
        emit comprarComida (_nombreComida, precioComidaToken, msg.sender);
        
        
    }
    
 // function para ver el historia de compra de comida de un cliente 
 
 function verHistorialCompraComida() public view returns(string [] memory){
     return HistorialComida[msg.sender];
     
     
 }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}