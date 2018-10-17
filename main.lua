-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

math.randomseed( os.time())


-------------------
-- Variáveis
-------------------

-- altura e largura do tabuleiro
local altura = display.contentHeight * .6
local largura = display.contentWidth
-- cores
local navioCor = { .6, .4, .4 }
local tiroCertoCor = { 0, .3, .1 }
local tiroErradoCor = { .5, .1, .1 }
local tabuleiroCor = { 0, .15, .60}
local botaoCor = { 0, .30, .50}

local navio = { }
local tabuleiro = { }
local jogador = { }

local jogadorUm
local ia
local texto = { }
local tamanhoNavio
local posicaoNavio = { }

-- Fases do jogo
local novoJogo
local batalha
local reiniciar

local iaPosicionarNavio
local iaAtirar
local posicionarNavioListener
local orientacaoNavioListener
local tapListener
local posicionarEvento
local removerPosicionarEvento
local orientacaoEvento
local removerOrientacaoEvento
local atirarListener
local atirarEvento
local removerAtirarEvento
local botao
local botaoListener
local botaoTexto
local definirTexto
local textoTopo 
local mudarCor
local venceu

------------------- 
-- Objetos
-------------------

-- Classe navio
-- dano = 0, posicao = {}, tamanho = 0
-- construtor para a criação de um novo objeto
function navio:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.dano = 0
	obj.posicao = {}
	obj.tamanho = 0
	return obj
end



-- Classe tabuleiro
-- navios = {}, graficoLinha = {}, graficoColuna = {}, retangulos = {}, ativo = false
-- construtor
function tabuleiro:new ()
      obj = {}
      setmetatable(obj, self)
      self.__index = self
      obj.navios = {}
      obj.graficoLinha = {}
      obj.graficoColuna = {}
      obj.retangulos = {}
      obj.ativo = false
      return obj
end

-- Classe jogador
-- pontuacao = 0, tabuleiro = tabuleiro:new(), ia = false
-- construtor
function jogador:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.pontuacao = 0
	obj.tabuleiro = tabuleiro:new()
	obj.ia = false
	return obj
end



--------------------
-- Métodos
--------------------

-- desenha na tela o tabuleiro
function tabuleiro:desenharGrafico( )
	
	for i = 1, 9 do
		self.graficoLinha[i] = display.newLine( 0, altura * i *.10 + 100, 
		largura, altura * i * .10 + 100 ) 

		self.graficoColuna[i] = display.newLine( largura * i * .10, 100, 
		 largura * i * .10, altura + 100) 
	end

end

-- desenha retângulos na tela para serem usados pelos listeners
function tabuleiro:desenharRetangulos( )
	for i=1,10 do
		
		self.retangulos[i] = {}
		for j=1, 10 do
			self.retangulos[i][j] = display.newRect( ( largura / 20 * ( i + i - 1) ) , (  altura / 20 * ( j + j - 1) + 100) , 
				largura / 10, altura / 10 )
			self.retangulos[i][j].fill = tabuleiroCor
			self.retangulos[i][j].alpha = .5
			self.retangulos[i][j].linha = i
			self.retangulos[i][j].coluna = j
			self.retangulos[i][j].ocupado = false
			self.retangulos[i][j].atingido = false
		end

	end

	self.ativo = true

end

-- Muda a cor de todas as células do tabuleiro
function tabuleiro:mudarCorCelulas( )
	for i=1,10 do
		for j=1,10 do
			mudarCor( self.retangulos[i][j], tabuleiroCor )
		end
	end
end

-- verifica se já existe um navio ocupando aquele espaço
-- recebe como parâmetros dois valores com as posições a serem checadas
-- retorna true se já estiver ocupado, senão retorna false
function tabuleiro:celulaOcupada( linha, coluna )	
	return self.retangulos[linha][coluna].ocupado
end

-- Esconde o tabuleiro modificando o alpha dos retângulos
function tabuleiro:esconder( )
	for i=1,10 do
		for j=1,10 do
			self.retangulos[i][j].alpha = 0
		end
	end
	self.ativo = false
end

-- Mostra o tabuleiro modificando o alpha dos retângulos
function tabuleiro:mostrar( )
	for i=1,10 do
		for j=1,10 do
			self.retangulos[i][j].alpha = .5
		end
	end

	self.ativo = true
end

-- Posiciona um novo navio no tabuleiro
function jogador:posicionarNavio( pos, tam ) 
	local novoNavio = navio:new()
	-- incrementar o loop
	local aux

	for i=1,4 do
		novoNavio.posicao[i] = pos[i]
	end
	novoNavio.tamanho = tam


	table.insert( self.tabuleiro.navios, novoNavio )
	
	if (pos[1] > pos[3]) then
		aux = -1
	else
		aux = 1
	end


	-- percorre o grafico no eixo x muda a cor e remove o listener
	for i = novoNavio.posicao[1], novoNavio.posicao[3], aux do
		local retangulo = self.tabuleiro.retangulos[i][novoNavio.posicao[2]]
		mudarCor ( retangulo, navioCor ) 
		retangulo.ocupado = true
		retangulo:removeEventListener( "tap", posicionarNavioListener )
	end

	if (pos[2] > pos[4]) then
		aux = -1
	else
		aux = 1
	end

	-- percorre o grafico no eixo y muda a cor e remove o listener
	for i = novoNavio.posicao[2], novoNavio.posicao[4], aux do
		local retangulo =  self.tabuleiro.retangulos[novoNavio.posicao[1]][i]
		mudarCor ( retangulo, navioCor )
		retangulo.ocupado = true
		retangulo:removeEventListener( "tap", posicionarNavioListener )
	end

	
end

-- atira na célula selecionada
function jogador:atirar( jogador2, linha, coluna)
	local acertou = false
	local pontuacao = self.pontuacao

	for i = 1, #jogador2.tabuleiro.navios do
		-- checa se o valor x e y estão entre as posições x1, x2 e y1, y2, respectivamente 

		if ( (linha >= jogador2.tabuleiro.navios[i].posicao[1] and linha <= jogador2.tabuleiro.navios[i].posicao[3])
			and 
			 (coluna >= jogador2.tabuleiro.navios[i].posicao[2] and coluna <= jogador2.tabuleiro.navios[i].posicao[4]) ) then
			acertou = true
			jogador2.tabuleiro.navios[i].dano = jogador2.tabuleiro.navios[i].dano + 1
			
			if ( jogador2.tabuleiro.navios[i].dano == jogador2.tabuleiro.navios[i].tamanho ) then
				pontuacao = pontuacao + jogador2.tabuleiro.navios[i].tamanho * 10
			end
		end
		
	end


	if ( acertou ) then
		jogador2.tabuleiro.retangulos[linha][coluna].fill = tiroCertoCor
	else
		jogador2.tabuleiro.retangulos[linha][coluna].fill = tiroErradoCor
	end

	jogador2.tabuleiro.retangulos[linha][coluna]:removeEventListener( "tap", atirarListener )
	jogador2.tabuleiro.retangulos[linha][coluna].atingido = true

	self.pontuacao = pontuacao

	return acertou

end



--------------------
-- Event Listeners
--------------------

posicionarNavioListener = function ( event )
	posicaoNavio[1] = event.target.linha
	posicaoNavio[2] = event.target.coluna

	if ( tamanhoNavio == 1 ) then
		posicaoNavio[3] = event.target.linha
		posicaoNavio[4] = event.target.coluna
		jogadorUm:posicionarNavio( posicaoNavio, tamanhoNavio )
		textoFundo( "Navio " .. tamanhoNavio.." posicionado" )
		tamanhoNavio = tamanhoNavio + 1
	else	
		removerPosicionarEvento()
		if ( orientacaoEvento() ) then
			textoFundo( "Navio não pode ser posicionado aqui" )
			posicionarEvento()
		else
			textoFundo( "Defina a orientação")
		end
		
	end

end

orientacaoNavioListener = function ( event )
	posicaoNavio[3] = event.target.linha
	posicaoNavio[4] = event.target.coluna
	jogadorUm:posicionarNavio( posicaoNavio, tamanhoNavio )
	textoFundo( "Navio " .. tamanhoNavio.." posicionado" )
	removerOrientacaoEvento()
	posicionarEvento()
	if ( tamanhoNavio == 5 ) then
		removerPosicionarEvento()
		jogadorUm.tabuleiro:esconder()
		ia.tabuleiro:desenharRetangulos()
		iaPosicionarNavio()
		ia.tabuleiro:mudarCorCelulas()
		batalha()
	else
		tamanhoNavio = tamanhoNavio + 1
	end
end

botaoListener = function ( )
	if ( jogadorUm.tabuleiro.ativo ) then
		jogadorUm.tabuleiro:esconder()
		ia.tabuleiro:mostrar()
		textoTopo( "Batalha - Atirar" )
		botaoTexto.text = "Ver Tabuleiro"

	else
		ia.tabuleiro:esconder()
		jogadorUm.tabuleiro:mostrar()
		textoTopo( "Batalha" )
		botaoTexto.text = "Ver Inimigo"
	end
end

atirarListener = function ( event )
	local linha = event.target.linha
	local coluna = event.target.coluna
	local acertou = jogadorUm:atirar( ia, linha, coluna )

	if ( acertou and not venceu( jogadorUm ) ) then
		textoFundo( "Acertou" )
		definirTexto()
	elseif ( not acertou ) then
		textoFundo( "Errou")
		ia.tabuleiro:esconder()
		jogadorUm.tabuleiro:mostrar()
		iaAtirar( )
	end
end

--------------------
-- Funções
--------------------

-- Define o estado de um novo jogo
novoJogo = function()
	jogadorUm = jogador:new( )
	ia = jogador:new( )
	ia.ia = true
	tamanhoNavio = 1
	-- 1 == linha 1, 2 == coluna 1, 3 == linha 2, 4 == coluna 2
	posicaoNavio = {}

	definirTexto()
	textoTopo( "Posicionar Navios" )
	jogadorUm.tabuleiro:desenharGrafico()
	jogadorUm.tabuleiro:desenharRetangulos()
	posicionarEvento()

end

-- Fase de batalha
batalha = function()

	--teste
	for i=1,5 do
		for k,v in pairs(jogadorUm.tabuleiro.navios[i].posicao) do
			print(k,v)
		end
	end
	

	atirarEvento()
	ia.tabuleiro:esconder()
	jogadorUm.tabuleiro:mostrar()
	textoTopo( "Batalha" )
	
	botao = display.newRoundedRect( largura / 2, display.contentHeight - 30, 100, 20, 5 )
	botao.fill = botaoCor
	botaoTexto = display.newText( "Ver Inimigo", largura / 2, display.contentHeight - 30 )
	botao:addEventListener( "tap", botaoListener )

end

-- Inicia a ia
-- preenche o tabuleiro da IA com os navios
iaPosicionarNavio = function ( )
	
	for i = 1, 5 do
		local ocupadoX = true
		local ocupadoY = true
		local pos = {}
		
		if (i ~= 1) then
			while ( ocupadoX or ocupadoY ) do
				pos = {}
				-- define a orientação do navio 1 == horizontal 2 == vertical
				local orientacao = math.random( 1, 2 )
				local linha1
				local linha2
				local coluna1
				local coluna2

				if ( orientacao == 1 ) then
					linha1 = math.random( 1, 10 - i )
					coluna1 = math.random( 1, 10 )
					linha2 = linha1 + i - 1
					coluna2 = coluna1
				else
					linha1 = math.random( 1, 10 )
					coluna1 = math.random( 1, 10 - i )
					linha2 = linha1
					coluna2 = coluna1 + i - 1
				end
				
				-- preenche a tabela de posições
				table.insert( pos, linha1 )
				table.insert( pos, coluna1 )
				table.insert( pos, linha2 )
				table.insert( pos, coluna2 )

				
				for i = pos[1], pos[3] do
					ocupadoX = ia.tabuleiro:celulaOcupada( i, pos[2] ) 
				end

				for i = pos[2], pos[4] do
					ocupadoY = ia.tabuleiro:celulaOcupada( pos[1], i ) 
				end

			end
		else
			local linha = math.random( 1, 10 )
			local coluna = math.random( 1, 10 )
			table.insert( pos, linha)
			table.insert( pos, coluna)
			table.insert( pos, linha)
			table.insert( pos, coluna)
		end
		
		ia:posicionarNavio( pos, i) 
	end
end

iaAtirar = function ( )
	local linha
	local coluna
	local acertou

	repeat 
		linha = math.random( 1, 10 )
		coluna = math.random( 1, 10 )
	until ( not jogadorUm.tabuleiro.retangulos[linha][coluna].atingido )

	acertou = ia:atirar( jogadorUm, linha, coluna )

	if ( acertou and not venceu( ia ) ) then
		definirTexto()
		iaAtirar()
	end

end


-- Adiciona os listeners para o posicionamento dos navios
posicionarEvento = function ( )	
	for i=1, 10 do
		for j=1, 10 do
			if ( jogadorUm.tabuleiro.retangulos[i][j].ocupado == false ) then
				jogadorUm.tabuleiro.retangulos[i][j]:addEventListener( "tap", posicionarNavioListener )
				mudarCor( jogadorUm.tabuleiro.retangulos[i][j], tabuleiroCor)
			end
		end
	end
end

-- Remove todos os eventos de posicionar do tabuleiro
removerPosicionarEvento = function ( )
	for i=1, 10 do
		for j=1, 10 do
			jogadorUm.tabuleiro.retangulos[i][j]:removeEventListener( "tap", posicionarNavioListener )
		end
	end
end

-- Modifica os listeners dos retângulos para aceitar apenas posições válidas
-- Retorna true se nenhum navio puder ser posicionado
orientacaoEvento = function ( )
	local valido = true
	local voltar = true
	local linhaNeg = posicaoNavio[1] - tamanhoNavio + 1
	local linhaPos = posicaoNavio[1] + tamanhoNavio - 1
	local colunaNeg = posicaoNavio[2] - tamanhoNavio + 1
	local colunaPos = posicaoNavio[2] + tamanhoNavio - 1

	if ( linhaNeg > 0 ) then
		for i = posicaoNavio[1], linhaNeg, -1 do
			if ( jogadorUm.tabuleiro:celulaOcupada( i, posicaoNavio[2]) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[linhaNeg][posicaoNavio[2]]:addEventListener( "tap", orientacaoNavioListener )
			jogadorUm.tabuleiro.retangulos[linhaNeg][posicaoNavio[2]].fill = tiroCertoCor
			voltar = false
		end
	end

-----------------------------------------------------------------------------------------

	if ( linhaPos < 11 ) then
		valido = true
		for i = posicaoNavio[1], linhaPos do
			if ( jogadorUm.tabuleiro:celulaOcupada( i, posicaoNavio[2] ) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[linhaPos][posicaoNavio[2]]:addEventListener( "tap", orientacaoNavioListener )
			jogadorUm.tabuleiro.retangulos[linhaPos][posicaoNavio[2]].fill = tiroCertoCor
			voltar = false
		end
	end

-----------------------------------------------------------------------------------------

	if ( colunaNeg > 0 ) then
		valido = true
		for i = posicaoNavio[2], colunaNeg, -1 do
			if ( jogadorUm.tabuleiro:celulaOcupada( posicaoNavio[1], i ) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[posicaoNavio[1]][colunaNeg]:addEventListener( "tap", orientacaoNavioListener )
			jogadorUm.tabuleiro.retangulos[posicaoNavio[1]][colunaNeg].fill = tiroCertoCor
			voltar = false
		end
	end


-----------------------------------------------------------------------------------------

	if ( colunaPos < 11 ) then
		valido = true
		for i = posicaoNavio[2], colunaPos do
			if ( jogadorUm.tabuleiro:celulaOcupada( posicaoNavio[1], i ) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[posicaoNavio[1]][colunaPos]:addEventListener( "tap", orientacaoNavioListener )
			jogadorUm.tabuleiro.retangulos[posicaoNavio[1]][colunaPos].fill = tiroCertoCor
			voltar = false
		end
	end

	return voltar
end

-- Remove o evento de orientação
removerOrientacaoEvento = function ( )
	for i=1, 10 do
		for j=1, 10 do
			jogadorUm.tabuleiro.retangulos[i][j]:removeEventListener( "tap", orientacaoNavioListener )
		end
	end
end

-- adiciona listener no tabuleiro do adversário
atirarEvento = function ()
	for i=1,10 do
		for j=1,10 do
			ia.tabuleiro.retangulos[i][j]:addEventListener( "tap", atirarListener )
		end
	end
end

-- remove os eventos de atirar
removerAtirarEvento = function ()
	for i=1,10 do
		for j=1,10 do
			ia.tabuleiro.retangulos[i][j]:removeEventListener( "tap", atirarListener )
		end
	end
end

-- Define o texto no topo da tela com o atual estado do jogo
-- Verifica se já existe um texto definido(se a função já foi chamada) para evitar overlap dos textos
definirTexto = function ( )
	local pontuacaoUm = jogadorUm.pontuacao
	local pontuacaoIa = ia.pontuacao

	texto.jogador = texto.jogador or display.newText( "Jogador", 50, 0)
	texto.ia = texto.ia or display.newText( "COM", largura - 50, 0 )

	if ( texto.pontuacaoUm == nil ) then
		texto.pontuacaoUm = display.newText( pontuacaoUm, 50, 30 )
		texto.pontuacaoIa = display.newText( pontuacaoIa, largura - 50, 30 )
	else
		texto.pontuacaoUm.text = pontuacaoUm
		texto.pontuacaoIa.text = pontuacaoIa
	end
	
end

-- Define o texto no topo da tela
textoTopo = function ( str )
	if ( texto.topo == nil ) then
		texto.topo = display.newText( str, largura / 2, 50 )
		texto.topo.size = 15
	else
		texto.topo.text = str
	end
end

-- Define o texto no fundo da tela
textoFundo = function ( str )
	if ( texto.fundo == nil ) then
		texto.fundo = display.newText( str, largura / 2, display.contentHeight - 50 )
		texto.fundo.size = 15
	else
		texto.fundo.text = str
	end
end


-- Muda a cor de um retâgulo
-- Recebe um retâgulo e a cor
mudarCor = function ( retangulo, cor )
	retangulo.fill = cor
end

-- verifica se um dos jogadores venceu o jogo
venceu = function ( jogador )
	if ( jogador.pontuacao == 150 ) then
		removerAtirarEvento()

		if ( jogador.ia ) then
			textoTopo( "Você perdeu" )	
		else
			textoTopo( "Você venceu" )
		end

		return true
	else
		return false
	end
end

--------------------
-- Jogo
--------------------

tapListener = function( event )

	if(event.target.ativo) then
		event.target.fill = navioCor
		event.target.ativo = false

	else
		event.target.fill = tiroErradoCor
		event.target.ativo = true
	end

end

novoJogo()

textoFundo('teste')
