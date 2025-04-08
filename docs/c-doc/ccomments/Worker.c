/**
 * PLANK_TYPE_WORKER:
 * 
 * The type for <link linkend="PlankWorker"><type>PlankWorker</type></link>.
 */
/**
 * plank_worker_add_task:
 * @self: the <link linkend="PlankWorker"><type>PlankWorker</type></link> instance
 * @func: (in): &nbsp;.  <para>function to be executed </para>
 * @func_target: (allow-none) (closure): user data to pass to @func
 * @func_target_destroy_notify: (allow-none): function to call when @func_target is no longer needed
 * @priority: (in): &nbsp;.  <para>priority of the given function </para>
 * 
 * Schedule given function to be run in our ThreadPool The given priority influences execution-time of the task depending on the currently scheduled amount of tasks.
 */
/**
 * plank_worker_add_task_with_result:
 * @self: the <link linkend="PlankWorker"><type>PlankWorker</type></link> instance
 * @g_type: The #GType for @g
 * @g_dup_func: A dup function for @g_type
 * @g_destroy_func: A destroy function for @g_type
 * @func: (in): &nbsp;.  <para>the function to be executed returning a typed result </para>
 * @func_target: (allow-none) (closure): user data to pass to @func
 * @func_target_destroy_notify: (allow-none): function to call when @func_target is no longer needed
 * @priority: (in): &nbsp;.  <para>priority of the given function </para>
 * @_callback_: (scope async): callback to call when the request is satisfied
 * @_user_data_: (closure): the data to pass to @_callback_ function
 * 
 * Schedule given function to be run in our ThreadPool The given priority influences execution-time of the task depending on the currently scheduled amount of tasks.
 * 
 * <para>AsyncReadyCallback will be executed on the main-thread through an idle with GLib.Priority.HIGH_IDLE.</para>
 * 
 * <emphasis>See also</emphasis>: <link linkend="plank-worker-add-task-with-result-finish"><function>plank_worker_add_task_with_result_finish()</function></link>
 */
/**
 * plank_worker_add_task_with_result_finish:
 * @self: the <link linkend="PlankWorker"><type>PlankWorker</type></link> instance
 * @_res_: a <link linkend="GAsyncResult"><type>GAsyncResult</type></link>
 * @error: location to store the error occurring, or %NULL to ignore
 * 
 * Schedule given function to be run in our ThreadPool The given priority influences execution-time of the task depending on the currently scheduled amount of tasks.
 * 
 * <para>AsyncReadyCallback will be executed on the main-thread through an idle with GLib.Priority.HIGH_IDLE.</para>
 * 
 * <emphasis>See also</emphasis>: <link linkend="plank-worker-add-task-with-result"><function>plank_worker_add_task_with_result()</function></link>
 * 
 * Returns: value from type @g_type. <para>the typed result </para>
 */
/**
 * plank_worker_get_default:
 * 
 * Returns: (transfer none): 
 */
/**
 * PlankWorker:
 */
/**
 * PlankWorkerClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-WORKER:CAPS"><literal>PLANK_TYPE_WORKER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * PlankTaskFunc:
 * @error: location to store the error occurring, or %NULL to ignore
 * @user_data: (closure): data to pass to the delegate function
 */
/**
 * PlankTaskPriority:
 */
