const Profile = require('../models/Profile');
const Aliment = require('../models/Aliment');
const ChatConversation = require('../models/ChatConversation');
const ChatMessage = require('../models/ChatMessage');
const { askGroq } = require('../services/groqService');

exports.sendMessage = async (req, res) => {
  try {
    const userId = req.userId;
    const { message, conversationId, context = {} } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({
        message: 'Le message est obligatoire',
      });
    }

    const cleanMessage = message.trim();

    const [profile, ingredients] = await Promise.all([
      Profile.getByUserId(userId),
      Aliment.findAllByUser(userId),
    ]);

    const activeConversationId = await getOrCreateConversation({
      conversationId,
      userId,
      message: cleanMessage,
      context,
    });

    await ChatMessage.create({
      conversationId: activeConversationId,
      role: 'user',
      content: cleanMessage,
      messageType: 'text',
      payload: {
        context,
      },
      recipeId: context.recipeId || null,
      foodItemId: context.foodItemId || null,
    });

    const reply = await askGroq({
      message: cleanMessage,
      profile,
      ingredients,
    });

    const finalReply =
      reply ||
      'Je suis la, mais je n ai pas reussi a generer une reponse pour le moment.';

    await ChatMessage.create({
      conversationId: activeConversationId,
      role: 'assistant',
      content: finalReply,
      messageType: 'text',
      payload: {
        provider: 'groq',
        model: process.env.GROQ_MODEL || 'llama-3.1-8b-instant',
      },
      recipeId: context.recipeId || null,
      foodItemId: context.foodItemId || null,
    });

    await ChatConversation.touch(activeConversationId);

    res.status(200).json({
      conversationId: activeConversationId,
      reply: finalReply,
    });
  } catch (error) {
    console.error('CHATBOT ERROR:', error.response?.data || error.message);

    res.status(500).json({
      message: 'Erreur lors de la generation de la reponse Chef AI',
    });
  }
};

exports.getConversations = async (req, res) => {
  try {
    const conversations = await ChatConversation.findAllByUser(req.userId);

    res.status(200).json({
      conversations: conversations.map(formatConversation),
    });
  } catch (error) {
    console.error('GET CHAT CONVERSATIONS ERROR:', error.message);

    res.status(500).json({
      message: 'Erreur lors de la recuperation des conversations',
    });
  }
};

exports.getConversationMessages = async (req, res) => {
  try {
    const conversationId = req.params.id;
    const conversation = await ChatConversation.findByIdForUser(
      conversationId,
      req.userId
    );

    if (!conversation) {
      return res.status(404).json({
        message: 'Conversation introuvable',
      });
    }

    const messages = await ChatMessage.findAllByConversation(conversationId);

    res.status(200).json({
      conversation: formatConversation(conversation),
      messages: messages.map(formatMessage),
    });
  } catch (error) {
    console.error('GET CHAT MESSAGES ERROR:', error.message);

    res.status(500).json({
      message: 'Erreur lors de la recuperation des messages',
    });
  }
};

const getOrCreateConversation = async ({
  conversationId,
  userId,
  message,
  context,
}) => {
  if (conversationId) {
    const belongsToUser = await ChatConversation.belongsToUser(
      conversationId,
      userId
    );

    if (belongsToUser) {
      return conversationId;
    }
  }

  return await ChatConversation.create({
    userId,
    title: buildTitle(message),
    mainSubject: detectSubject(message),
    recipeId: context.recipeId || null,
    foodItemId: context.foodItemId || null,
    context,
  });
};

const buildTitle = (message) => {
  if (message.length <= 60) return message;
  return `${message.substring(0, 57)}...`;
};

const detectSubject = (message) => {
  const normalized = message.toLowerCase();

  if (normalized.includes('recette') || normalized.includes('recipe')) {
    return 'recipe';
  }

  if (normalized.includes('calorie') || normalized.includes('nutrition')) {
    return 'nutrition';
  }

  if (normalized.includes('course') || normalized.includes('shopping')) {
    return 'shopping';
  }

  if (normalized.includes('ingredient') || normalized.includes('inventaire')) {
    return 'inventory';
  }

  return 'general';
};

const formatConversation = (conversation) => ({
  id: conversation.id,
  title: conversation.titre,
  mainSubject: conversation.sujetPrincipal,
  recipeId: conversation.recipeId,
  foodItemId: conversation.foodItemId,
  context: parseJsonField(conversation.contexte),
  status: conversation.statut,
  lastMessageAt: conversation.lastMessageAt,
  lastMessage: conversation.lastMessage,
});

const formatMessage = (message) => ({
  id: message.id,
  conversationId: message.conversationId,
  role: message.role,
  content: message.content,
  messageType: message.messageType,
  payload: parseJsonField(message.payload),
  recipeId: message.recipeId,
  foodItemId: message.foodItemId,
  position: message.position,
  createdAt: message.createdAt,
});

const parseJsonField = (value) => {
  if (!value) return null;
  if (typeof value !== 'string') return value;

  try {
    return JSON.parse(value);
  } catch (_) {
    return value;
  }
};
