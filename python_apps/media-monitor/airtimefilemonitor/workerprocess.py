from mediaconfig import AirtimeMediaConfig
import mediamonitorcommon

class MediaMonitorWorkerProcess:

    #this function is run in its own process, and continuously
    #checks the queue for any new file events.
    def process_file_events(self, queue, notifier):
        while True:
            try:
                event = queue.get()
                notifier.logger.info("received event %s", event)
                if event['mode'] == AirtimeMediaConfig.MODE_CREATE:
                    filepath = event['filepath']
                    if mediamonitorcommon.test_file_playability(filepath):
                        notifier.update_airtime(event)
                    else:
                        notifier.logger.warn("Liquidsoap integrity check for file at %s failed. Not adding to media library.", filepath)
                else:
                    notifier.update_airtime(event)
            except Exception, e:
                notifier.logger.error(e)
