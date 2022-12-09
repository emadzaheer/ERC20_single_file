// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract ERC20Token {
    function name() virtual public view returns ( string memory);
    function symbol() virtual public view returns (string memory);
    function decimals() virtual public view returns (uint8);
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address _owner) virtual public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) virtual public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
    function approve(address _spender, uint256 _value) virtual public returns (bool success);
    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership( address _to) public {
        require(msg.sender == owner);
        newOwner = _to;    
    }

    function acceptOwnership() public {    //we require the new owner to accept his ownership
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    } 
}


contract Token is ERC20Token, Owned{
    string public _name;
    string public _symbol;
    uint8 public _decimal; 
    uint public _totalsupply;
    address public _minter;

    mapping(address => uint) balances;

    constructor(){
        _symbol = "EZ";
        _name= "ME token";
        _decimal = 0;
        _totalsupply =  100;
        _minter = 0xC5959B47B827ed5ECfBC946c8125C4485a45375e;
        balances[_minter] = _totalsupply;                     //totalsupply given to the minter adress which can now distribute it. 
        emit Transfer(address(0), _minter, _totalsupply);     //(from, to, amount)

    }

    function name() public override view returns (string memory){
        return _name;
    }

    function symbol() public override view returns (string memory){
        return _symbol;
    }
    function decimals() public override view returns (uint8){
        return _decimal;
    }
    function totalSupply() public override view returns (uint256){
        return _totalsupply;
    }
    function balanceOf(address _owner) public override  view returns (uint256 balance){
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns (bool success){     //transfer is from the msg.sender to another address. Similar to transfer from so we
        return transferFrom(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){   //transfer from someone else's address to another address
        require( balances[_from] > _value);           
        balances[_from] -= _value;
        balances[_to]   += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success){
        return true;           //not implementing this for now. 
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining){
        return 0;                        //not implementing this for now. 
    }

    function mint(uint _amount) public returns(bool) {
        require( msg.sender == _minter);    //state variable in the constructor
        balances[_minter]   += _amount;
        _totalsupply        -= _amount; 
        return true;
    }

    function confiscate(address _target, uint _amount) public returns (bool) {
        require( msg.sender == _minter);    //state variable in the constructor
        
        if ( balances[_target] >= _amount ) {
            balances[ _target ]  -= _amount;
            _totalsupply         -= _amount;     //we burn(remove forever by sending to address(0)). 
        } 
        else{
            _totalsupply      -= balances[_target];
            balances[_target]  = 0; 
        }
        return true;
    }

}


//we can add our token to metamask with the token contract address
