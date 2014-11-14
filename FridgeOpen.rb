## '/dev/tty.usbmodem1411'

require 'serialport'
require 'pg'
require 'sinatra'

$x = nil
$conn = nil

get '/start' do
	sp = SerialPort.new('/dev/tty.usbmodem1411', 9600, 8, 1, SerialPort::NONE)
	$conn = PG::Connection.open(:dbname => 'ard_loc')
	if $x then
		"Service already running"
	else
		$conn.exec_params('delete from event')
		counter = 1
		$x = Thread.new{
			while true
				ev = sp.getc
				if ev
					puts ev
					res = $conn.exec_params('insert into event (id, event_type,date_from) values ($1,$2,$3)',
						[counter,ev,Time.now])
					counter+=1
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
		res = $conn.exec('select count(1) from event')
		"Number of records: " + res [0] ['count']
	else "Number of records: " + "0"
	end
end

## nevar inicializēt seriālo portu - pārgāju uz getc - ok
## atgriezto vērtību /status neatgriež "can not convert hash to string" ok
## res = conn.exec('select count(1) from event') - ok

## Todo ruby
## tikt vaļā no globāliem mainīgajiem
## jāiztīra ports pirms sākam lasīt

## Todo mobap
## Darbību izdarīšana uz pogām
## Rest servisu izsaukšana ObjectiveC
## Rest servisu atbildes saņemšana un atrādīšana

## Todo ieviešanai
## Izveidot vidi uz linux mašīnas (pg serveris, ruby gemsets, )
## iedarbināt testu (seriālā porta darbību, seriālā porta pieejamība?)
## Pārbaudīt, kā servisus var izsaukt no citurienes (no cita datora) - atvērt portu?
## ledusskapja slēdža risinājums