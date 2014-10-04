var fs = require('fs'),
    path = require('path');

var queue_file = '/tmp/haraka.eml',
    stream_opts = {
        flags: 'a',
        encoding: 'utf-8'
    };

exports.register = function() {
    var config_path = this.config.get('queue/file_output') || queue_file;

    queue_file = path.resolve(config_path);
};

/**
 * append the incoming mail to the queue file.
 * @param  {Function} next       processing callback
 * @param  {Object}   connection connection information
 */
exports.hook_queue = function(next, connection) {
    var ws = fs.createWriteStream(queue_file, stream_opts);

    ws.once('close', function () {
        return next(OK);
    });

    connection.transaction.message_stream.pipe(ws);
};