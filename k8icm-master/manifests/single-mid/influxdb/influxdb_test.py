from influxdb import InfluxDBClient

from datetime import datetime

import time

client = InfluxDBClient(host='influxdb.default', port=8086, database='pods')



def write_to_influx(data):

    now = datetime.utcnow().isoformat() + 'Z'

    json_body = [

        {

            "measurement": "pod_shutdown_data",

            "tags": {



            },

            "time": str(now),

            "fields": data

        }

    ]



    





    try:

        client.create_database('pods')

        client.write_points(json_body)



        #sanitycheck



        result = client.query('select * from pod_shutdown_data;')

        print('result',str(result))

        

    except Exception as e:

        print('error',str(e))





i = 1

while True:

    i += 1

    data = {

        'somekey':i

    }

    write_to_influx(data)

    time.sleep(5)