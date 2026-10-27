#ifndef SECURITY_PLUGIN_H
#define SECURITY_PLUGIN_H

#ifdef __cplusplus
extern "C" {
#endif

    // Hàm kiểm tra AI Bot
    int check_and_block_ai_bot(const char* user_agent_str);

    // Hàm xử lý lịch sử đấu
    int process_match_history_action(int user_id, int match_id, int action_type);

#ifdef __cplusplus
}
#endif

#endif // SECURITY_PLUGIN_H
