interface IExternalPriceFeed {
   function readAsUint256(address sender) external view returns (uint256);
   function getLatestPrice() external view returns (uint256);
}
