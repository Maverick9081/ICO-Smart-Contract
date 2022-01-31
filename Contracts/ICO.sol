

pragma solidity ^0.8.0;

import "./NiceToken.sol";


contract ICO is NiceToken  {
    
    address public admin;
    uint public ico_start_time;
    uint public ico_end_time;
    uint public token_price;
    uint public minted_tokens;
    uint public current_ICO_phase;

    uint private pre_sale_tokens=3*10**16;
    uint private seed_sale_tokens =5*10**16;
    uint private final_sale_tokens=2*10**16;
   

    constructor () {
        admin = msg.sender;
    }

    modifier onlyadmin {
        require(msg.sender == admin);
        _;
    }

    function contract_handler(uint start_time,uint end_time,uint _token_price) public onlyadmin {
        require(block.timestamp > ico_end_time);
        require(current_ICO_phase <3);
        require(start_time < end_time);
        require(_token_price > 0);

        token_price = _token_price;
        ico_start_time = block.timestamp + start_time;
        ico_end_time = block.timestamp + end_time;
        current_ICO_phase ++;
    }

    function buy_token(address buyer)public payable  {
        require(block.timestamp >ico_start_time && block.timestamp < ico_end_time);
        uint wei_amount = msg.value;
        require(wei_amount >= token_price);
        uint amount = get_token_amount(wei_amount);
        mint_tokens(buyer,amount);
    }

    function token_remains_to_be_sold() public view returns(uint) 
    {
        if(current_ICO_phase==1){
            return pre_sale_tokens - minted_tokens;
        }
        else if(current_ICO_phase==2){
            return pre_sale_tokens + seed_sale_tokens - minted_tokens;
        } 
        else if(current_ICO_phase ==3){
            return totalSupply() - minted_tokens;
        }
    }

    function get_token_amount(uint wei_amount) internal  returns (uint) {
        return wei_amount/token_price;
    }

    function mint_tokens(address buyer,uint amount)internal {
        uint tokens = minted_tokens + amount;
        require(
                    current_ICO_phase ==1 && tokens <= pre_sale_tokens ||
                    current_ICO_phase ==2 && tokens <= seed_sale_tokens + pre_sale_tokens ||
                    current_ICO_phase ==3 && tokens <= final_sale_tokens + seed_sale_tokens + pre_sale_tokens
                );
        _mint(buyer,amount);
        minted_tokens += amount;
    }

    function total_funds_raised()public view returns (uint){
        uint balance = address(this).balance;
        return balance;
    }

    function current_sale_remaining_time() public view returns (uint) {
        if(block.timestamp > ico_end_time){
            return 0;
        }
        else{
             return ico_end_time - block.timestamp;
        }
    }

    function transfer_raised_funds(address payable account)public  onlyadmin {
        require(current_ICO_phase ==3 && block.timestamp >ico_end_time);
        account.send(address(this).balance);
    }

    function mint_remaining_tokens (address receiver)public onlyadmin{
        require( current_ICO_phase ==3 && block.timestamp >ico_end_time);
        _mint(receiver,token_remains_to_be_sold());
        minted_tokens += token_remains_to_be_sold();
    }

}

