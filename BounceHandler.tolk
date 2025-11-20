;; BounceHandler.tolk
;; Contract A: Sends message and handles the Rich Bounce
;; 合约 A：发送消息并处理 Rich Bounce 回弹

#include "imports/stdlib.fc";

;; Storage variables: Address of Contract B
;; 存储变量：合约 B 的地址
(slice) load_data() inline {
    slice ds = get_data().begin_parse();
    return ds~load_msg_addr();
}

() save_data(slice target_address) impure inline {
    set_data(begin_cell().store_slice(target_address).end_cell());
}

;; Main entry point
;; 主入口函数
() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    
    ;; 1. Parse the message flags to check if it is a "Bounced" message
    ;; 1. 解析消息标志位，检查这是否是一条“回弹”（Bounced）消息
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);

    ;; Check the "bounced" flag (the first bit of the flags)
    ;; 检查 "bounced" 标志（标志位的第1位）
    if (flags & 1) {
        ;; --- HANDLE RICH BOUNCE HERE ---
        ;; --- 在这里处理 RICH BOUNCE ---
        
        ;; The in_msg_body contains the data returned from Contract B (up to 224 bits)
        ;; in_msg_body 包含了合约 B 退回的数据（最多 224 位）
        
        ;; For this task, we just accept it. In a real app, you might revert a database state.
        ;; 对于本任务，我们只需接收它。在实际应用中，你可能会回滚数据库状态。
        
        return (); ;; End execution successfully / 执行结束
    }

    ;; 2. If it is NOT a bounced message (it's a normal command from wallet)
    ;; 2. 如果不是回弹消息（即来自钱包的普通指令）
    
    ;; Load Contract B address
    ;; 读取合约 B 地址
    slice target_address = load_data();

    ;; Create a message to Contract B
    ;; 创建发往合约 B 的消息
    var msg = begin_cell()
        .store_uint(0x18, 6)           ;; nobounce(0) + bounce(1) + ... -> 0x18 ensures bounce=true / 确保开启回弹
        .store_slice(target_address)   ;; Destination / 目的地
        .store_coins(0)                ;; Value (will be overridden by mode 64) / 金额
        .store_uint(0, 1 + 4 + 4 + 64 + 32 + 1 + 1) ;; Default headers / 默认头
        .store_slice("Hello B")        ;; The data payload / 数据负载
        .end_cell();

    ;; Send message to B. Mode 64 = send all remaining gas
    ;; 发送消息给 B。模式 64 = 发送所有剩余 Gas
    send_raw_message(msg, 64);
}
