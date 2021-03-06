(* ---------------- Main ---------------- *)

open Absyn
open Cek
open Decoder
open Printf

let format_time : float -> string =
  fun t ->
  if t >=1.0 then sprintf "%.2fs" t
  else sprintf "%.2fms" (t *. 1000.0)


let time_execution : name term -> name term * float =
  fun t ->
    let time1 = Sys.time () in
    let result = compute_cek [] IntMap.empty t in
    let etime = Sys.time () -. time1 in
    (result, etime)

(* Run the program `count` times, printing the individual
   execution times and then the average at the end. *)
let time_ntimes : name term -> int -> unit =
  fun t count ->
  let rec aux t k total =
    if k <= 0 then total
    else let (_,time) = time_execution t in
         printf "%f\n%!" time;
         aux t (k-1) (total +. time)
  in let total_time = aux t count 0.0 in
     printf "# Average time over %d runs = %s\n" count
       (format_time ((total_time /. (float_of_int count))))

let usage () =
  let cmd = Filename.basename Sys.executable_name in
  printf "Usage: %s <file> or %s -t <count> <file>\n" cmd cmd;
  exit 1

let _ =
  match (Array.to_list Sys.argv) with
  | [_; file] ->
     let Program (_,_,_,body) = Decoder.read_cbor file in
     let (result, time) = time_execution body in
     begin
       printf "%s\n" (show_term result);
       printf "Execution time: %s\n" (format_time time)
     end
  | [_; "-t"; n; file] ->
     let Program (_,_,_,body) = Decoder.read_cbor file in
     time_ntimes body (int_of_string n)
  | _ -> usage ()
