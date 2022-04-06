pragma solidity ^0.8.10;

import './interfaces/IUniswapFactory.sol';
import './interfaces/IUniswapPair.sol';
import './interfaces/IUniswapRouter.sol';
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AnyDex is Ownable {
    

    IUniswapV2Factory iFactory;
    IUniswapV2Pair iPair;
    IUniswapV2Router02 iRouter;

    address[] routers;
    address[] factories;

    // all known pairs
    mapping(address => address) routerPairs;

    mapping(address => address) routerFactory;

    mapping(address => bool) isFactory;
    
    // is this address a router address
    mapping(address => bool) isRouter;

    // takes router address and maps to all known pairs for that router
    mapping(address => mapping(address => address)) routerToPairs; 

    // getters

    function getisRouter(address _router) public view returns (bool) {
        return isRouter[_router];
    }

    function getRouterToPairs(address _router, address _pair0) public view returns(address) {
        address pair1 = routerToPairs[_router][_pair0];
        return  pair1;
    }

    // setters

    function addFactory(address _factory) public onlyOwner {

    }

    function setRouter(address _router) public onlyOwner {
        require(!isRouter[_router], "router already known");
        isRouter[_router] = true;
        routers.push(_router);
    }

    function setRouterToPairs(address _router, address _pair0, address _pair1) public onlyOwner {
        routerToPairs[_router][_pair0] = _pair1;
    }

    function getRouterFactory(address _router) public onlyOwner {
        require(isRouter[_router] == true, "router not known");
        address factory = IUniswapV2Router02(_router).factory();
        factories.push(factory);
        routerFactory[_router] = factory;
        isFactory[factory] == true;
        getFactoryPairs(factory, _router);
    }

    function getFactoryPairs(address _factory, address _router) public onlyOwner {
        require(isFactory[_factory] == true, "factory not known");
        uint pairLen = IUniswapV2Factory(_factory).allPairsLength();
        for(uint x = 0; x < pairLen; x++) {
            while (x < pairLen){
                address pairAddr = IUniswapV2Factory(_factory).allPairs(x);
                IUniswapV2Pair pair = IUniswapV2Pair(pairAddr);
                address token0 = pair.token0();
                address token1 = pair.token1();

                routerToPairs[_router][token0] = token1;
            }
        }
    }

}