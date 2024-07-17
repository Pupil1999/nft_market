"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
var viem_1 = require("viem");
var chains_1 = require("viem/chains");
var dotenv_1 = require("dotenv");
function getLatest100BlocksTransferEvents() {
    return __awaiter(this, void 0, void 0, function () {
        var client, latestBlockNumber, startBlock, endBlock, filter, logs, outputs;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    (0, dotenv_1.config)();
                    client = (0, viem_1.createPublicClient)({
                        chain: chains_1.mainnet,
                        transport: (0, viem_1.http)("https://mainnet.infura.io/v3/".concat(process.env.INFURA_API_KEY)),
                    });
                    return [4 /*yield*/, client.getBlockNumber()];
                case 1:
                    latestBlockNumber = _a.sent();
                    startBlock = latestBlockNumber - BigInt(99);
                    endBlock = latestBlockNumber;
                    return [4 /*yield*/, client.createEventFilter({
                            address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
                            event: (0, viem_1.parseAbiItem)('event Transfer(address indexed from, address indexed to, uint256 value)'),
                            fromBlock: startBlock,
                            toBlock: endBlock,
                        })];
                case 2:
                    filter = _a.sent();
                    return [4 /*yield*/, client.getFilterLogs({ filter: filter })];
                case 3:
                    logs = _a.sent();
                    outputs = logs.map(function (log) {
                        var _a = log.args, from = _a.from, to = _a.to, value = _a.value;
                        var txid = log.transactionHash;
                        return "Transfer from ".concat(from, " to ").concat(to, " USDC ").concat(value === null || value === void 0 ? void 0 : value.toString(), ", txID:").concat(txid);
                    });
                    outputs.forEach(function (log) { return console.log(log); });
                    return [2 /*return*/];
            }
        });
    });
}
function main() {
    return __awaiter(this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            // Execute the function to get the latest 100 blocks Transfer events
            getLatest100BlocksTransferEvents().catch(console.error);
            return [2 /*return*/];
        });
    });
}
main().catch(function (error) {
    console.error("Uncaught Error:", error);
});