const SUPABASE_URL = process.env.SUPABASE_URL || 'https://vtcdwgtnwuxlmictwglk.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_PUBLISHABLE_KEY || 'sb_publishable_oSvo5cig8BcmN-90GH9Oaw_4sS_AmDx';
const send=(res,status,data)=>{res.statusCode=status;res.setHeader('Content-Type','application/json; charset=utf-8');res.setHeader('Cache-Control','no-store');res.end(JSON.stringify(data))};
const cookies=req=>Object.fromEntries(String(req.headers.cookie||'').split(';').map(x=>x.trim()).filter(Boolean).map(x=>{const i=x.indexOf('=');return i<0?[x,'']:[x.slice(0,i),decodeURIComponent(x.slice(i+1))]}));
const read=async req=>{if(req.body&&typeof req.body==='object')return req.body;let s='';for await(const c of req)s+=c;return s?JSON.parse(s):{}};
export default async function handler(req,res){
 try{
  if(req.method!=='POST')return send(res,405,{error:'Method not allowed'});
  const token=cookies(req).pt_access;if(!token)return send(res,401,{error:'Authentication required'});
  const b=await read(req);if(!b.id||!['open','done'].includes(b.status))return send(res,400,{error:'Invalid status update'});
  const r=await fetch(`${SUPABASE_URL}/rest/v1/promises?id=eq.${encodeURIComponent(b.id)}`,{method:'PATCH',headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${token}`,'Content-Type':'application/json',Prefer:'return=representation'},body:JSON.stringify({status:b.status,updated_at:new Date().toISOString()})});
  const out=await r.json().catch(()=>[]);if(!r.ok)return send(res,r.status,{error:out?.message||out?.hint||'Database update failed'});
  if(!out.length)return send(res,404,{error:'Promise not found or not permitted'});
  return send(res,200,{ok:true,promise:out[0]});
 }catch(e){console.error(e);return send(res,500,{error:'Could not update promise',detail:e.message})}
}
