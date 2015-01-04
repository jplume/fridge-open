## '/dev/tty.usbmodem1411 - macos
## '/dev/ttyACM0 - elementaryOS
## usb_serial_device, db_name, db_user
## jāpievieno tiesības uz usb serial portu: 
## sudo adduser janis dialout
## sudo chmod a+rw /dev/ttyACM0
## jāpieviento pg serverim lietotājs, kas vienāds ar opsistēmas lietotājvārdu


## event tabulai nav privilēģijas

require 'serialport'
require 'pg'
require 'sinatra'

$x = nil
$conn = nil
set :bind, '0.0.0.0' ## lai servisiem piekļūtu no tīkla

get '/start' do
	sp = SerialPort.new('/dev/ttyACM0', 9600, 8, 1, SerialPort::NONE)
	sp.flush_input
	$conn = PG::Connection.open(:dbname => 'ard_loc')
	if $x then
		"Service already running"
	else
		$conn.exec_params('delete from event')
		counter = 1
		$x = Thread.new{
			while true
				ev = sp.getc
				if (['O','C','T'].include? ev)
					puts ev
				counter+=1
					res = $conn.exec_params('insert into event (id, event_type,date_from) values ($1,$2,$3)',
						[counter,ev,Time.now])
				end
				if ev == 'T'
					temperature = sp.readline
					puts temperature
					res = $conn.exec_params('update event set num_value=$1 where id=$2',
						[temperature.to_f,counter])		
				end
			end	
		}
		"Service started!"
	end
end

get '/stop' do
	if $x then 
		$x.exit
		$x=nil
	end
  	"Service stopped!"
end

get '/status' do
	if $conn then 
		res = $conn.exec('select count(1) from event where event_type in (\'O\')')
		x = "Fridge opening times: " + res [0] ['count']
		res = $conn.exec('select avg (num_value) from event where event_type=\'T\'')
		x= x + " Average temperature: " + res [0] ['avg'].to_s
		res = $conn.exec('select sum (c.date_from-o.date_from) from event o, event c where o.event_type=\'O\' and c.id = (select min (id) from event x where x.id > o.id and x.event_type=\'C\')')
		x= x + " Opening time since restart: " + res [0] ['sum'].to_s
	else "Not connected to database!"
	end
end



## Todo ruby
## tikt vaļā no globāliem mainīgajiem
## jāiztīra ports pirms sākam lasīt - OK

## Todo mobap
## Darbību izdarīšana uz pogām
## Rest servisu izsaukšana ObjectiveC
## Rest servisu atbildes saņemšana un atrādīšana

## Todo ieviešanai
## Izveidot vidi uz linux mašīnas (pg serveris, ruby gemsets, ) OK
## iedarbināt testu (seriālā porta darbību, seriālā porta pieejamība?) OK
## Pārbaudīt, kā servisus var izsaukt no citurienes (no cita datora) - atvērt portu? OK
