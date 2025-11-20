;; AlwaysFail.tolk
;; Contract B: Rejects everything to trigger a Bounce
;; 合约 B：拒绝一切消息以触发回弹

#include "imports/stdlib.fc";

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    
    ;; Parse flags just to be safe (optional)
    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);

    ;; If it's already a bounced message, ignore it to prevent infinite loops
    ;; 如果这已经是回弹消息，忽略它以防止无限循环
    if (flags & 1) {
        return ();
    }

    ;; --- TRIGGER BOUNCE ---
    ;; --- 触发回弹 ---
    
    ;; Throwing an exception with a non-zero code triggers a transaction failure.
    ;; Since the incoming message had bounce=true, TVM will generate a bounce message.
    ;; 抛出一个非零代码的异常会触发交易失败。
    ;; 由于传入的消息设置了 bounce=true，TVM 会自动生成回弹消息。
    
    throw(777); ;; Error code 777 / 错误代码 777
}
