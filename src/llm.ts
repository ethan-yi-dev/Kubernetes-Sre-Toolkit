// src/llm.ts


// model configure
// gpt-xx  https://api.openai.com/v1
export type Model = {
    apiKey: string
    model: string
    baseUrl?: string
    maxTokens?: number
}


export type ContentBlock =
    | { type: 'text'; text: string }
    | { type: 'tool_use'; id: string; name: string; input: unknown }
    | { type: 'tool_result'; tool_use_id: string; content: string }


export type Message = {
    role: 'user' | 'assistant'
    content: string | ContentBlock[]
}


// Context
export type Context = {
    systemPrompt?: string
    messages: Message[]
}

// united flow output from llm
export type StreamEvent = 
  | { type: 'text_delta'; delta: string }
  | { type: 'tool_call'; id: string; name: string; args: unknown }
  | { type: 'done'; stopReason: 'end_turn' | 'tool_use' | 'max_tokens' | 'aborted' }
  | { type: 'error'; error: Error }

// agent imported tool
export type ToolDef = {
    name: string
    description: string
    parameters: object
} 