/**
 * accept all incoming mails. this will simply call the
 * next member in the processing chain.
 * @param  {Function} next       next processor
 */
exports.hook_rcpt = function (next) {
    next(OK);
}