import{c as w,_ as q}from"./CKdEhTHU.js";import{D as E,E as B,G as g,x as N,H as P,r as m,k as S,c as V,b as x,w as y,B as u,o as D,a as A,V as b,d as k,I as U}from"./Bh59aRpc.js";import{u as R}from"./DHrnonhk.js";import"./jyi1f3K3.js";import"./B4cRk-tp.js";import"./DNJGKzx0.js";import"./B9i1-_oj.js";import"./cefNi3wq.js";import"./BvlIk6eM.js";/* empty css        */import"./a5OFAv6S.js";const $=()=>{const e=E(),n=B(),p=g(()=>e.isAuthenticated),s=g(()=>e.user),r=g(()=>n.query.redirect?String(n.query.redirect):"/");return{isAuthenticated:p,user:s,redirectPath:r,login:async(c,o)=>{const _=N();try{const a=await _.postWithString("accounts/token/",{username:c,password:o});return await e.login(a)}catch{return!1}},logout:()=>{e.logout()},fetchUser:async()=>e.fetchUser(),hasPermission:c=>{if(!e.user)return!1;const o=e.user;return o.permissions&&o.permissions.includes(c)}}},C={class:"max-w-md mx-auto mt-8"},F={class:"text-center mt-4"},G={class:"text-center mt-4"},Q={__name:"login",setup(e){const n=P(),{showNotification:p}=U(),s=$(),r=m(!1),i=m(""),f=m({}),{handleApiErrors:h,resetErrors:v}=R({error:i,fieldErrors:f}),c=m({username:"",password:""}),o=[{key:"username",label:"Имя пользователя",type:"text",required:!0,cols:12,sm:12,md:12,prepend:"mdi-account",validation:w().required("Имя пользователя обязательно")},{key:"password",label:"Пароль",type:"password",required:!0,cols:12,sm:12,md:12,prepend:"mdi-lock",validation:w().required("Пароль обязателен")}],_=async a=>{var t,l;r.value=!0,v();try{await s.login(a.username,a.password)?(p({message:"Авторизация успешна.",type:"success"}),n.push(s.redirectPath.value)):i.value="Не удалось войти в систему. Пожалуйста, проверьте введенные данные."}catch(d){(t=d.response)!=null&&t.data?h(d.response.data):i.value="Произошла ошибка при входе. Попробуйте позже.",h(((l=d.response)==null?void 0:l.data)||{})}finally{r.value=!1}};return S(()=>{s.isAuthenticated.value&&n.push(s.redirectPath.value)}),(a,t)=>{const l=q;return D(),V("div",C,[x(l,{title:"Вход",fields:o,"initial-data":u(c),loading:u(r),error:u(i),"field-errors":u(f),"submit-button-text":u(r)?"Вход...":"Вход","show-cancel":!1,"show-reset":!1,onSubmit:_},{"additional-fields":y(()=>[A("div",F,[x(b,{variant:"text",color:"primary",to:"/register",class:"text-none"},{default:y(()=>t[0]||(t[0]=[k(" Нет аккаунта? Зарегистрироваться ")])),_:1})]),A("div",G,[x(b,{variant:"text",color:"primary",to:"/reset-password",class:"text-none"},{default:y(()=>t[1]||(t[1]=[k(" Забыли пароль? Восстановить ")])),_:1})])]),_:1},8,["initial-data","loading","error","field-errors","submit-button-text"])])}}};export{Q as default};
