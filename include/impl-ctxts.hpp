namespace gpumagi {

//
// Implementation of execution contexts. (Currently global variables.)
static              TraversalPassContext   pass_ctxt;
static thread_local TraversalThreadContext thread_ctxt;
static thread_local TraversalTraceContext  trace_ctxt; // Only used during trace calls.


} // namespace gpumagi
